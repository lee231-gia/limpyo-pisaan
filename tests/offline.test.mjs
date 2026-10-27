import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import vm from 'node:vm';

async function worker() {
  const handlers = {}, records = new Map(), removed = [];
  let offline = false;
  const key = request => typeof request === 'string' ? request : request.url;
  const cache = {
    async addAll(urls) { for (const url of urls) records.set(url,new Response('cached '+url)); },
    async put(request,response) { records.set(key(request),response); },
    async match(request) { return records.get(key(request))?.clone(); }
  };
  const scope='https://example.github.io/my-app/';
  const context=vm.createContext({
    self:{registration:{scope},addEventListener:(type,fn)=>handlers[type]=fn,skipWaiting:async()=>{},clients:{claim:async()=>{}}},
    caches:{open:async()=>cache,keys:async()=>['limpyo-pisaan:/my-app/:old','limpyo-pisaan:/another-app/:v1','unrelated'],delete:async name=>removed.push(name)},
    URL, Response,
    fetch:async request=>{if(offline)throw new Error('Offline');return new Response('online '+key(request));}
  });
  vm.runInContext(await readFile(new URL('../sw.js',import.meta.url),'utf8'),context);
  return {handlers,records,removed,scope,setOffline:()=>offline=true};
}
test('offline launch resolves the shell under the repository path',async()=>{
  const w=await worker();let promise;
  w.handlers.install({waitUntil:p=>promise=p});await promise;
  assert.ok(w.records.has(w.scope+'index.html'));
  assert.ok([...w.records.keys()].every(url=>url.startsWith(w.scope)));
  w.setOffline();
  w.handlers.fetch({request:{url:w.scope,method:'GET',mode:'navigate'},respondWith:p=>promise=p});
  assert.equal(await (await promise).text(),'cached '+w.scope+'index.html');
});
test('offline cache serves modules without substituting HTML for missing assets',async()=>{
  const w=await worker();let promise;
  w.handlers.install({waitUntil:p=>promise=p});await promise;w.setOffline();
  w.handlers.fetch({request:{url:w.scope+'app.js',method:'GET',mode:'cors'},respondWith:p=>promise=p});
  assert.equal(await (await promise).text(),'cached '+w.scope+'app.js');
  w.handlers.fetch({request:{url:w.scope+'missing.js',method:'GET',mode:'cors'},respondWith:p=>promise=p});
  assert.equal((await promise).status,503);
});
test('worker leaves sibling apps, external requests and their caches alone',async()=>{
  const w=await worker();let intercepted=false,promise;
  for(const url of ['https://example.github.io/another-app/app.js','https://fonts.googleapis.com/css2']) {
    w.handlers.fetch({request:{url,method:'GET'},respondWith:()=>intercepted=true});
  }
  assert.equal(intercepted,false);
  w.handlers.activate({waitUntil:p=>promise=p});await promise;
  assert.deepEqual(w.removed,['limpyo-pisaan:/my-app/:old']);
});
test('opening the development preview cannot replace the cached mobile app shell',async()=>{
  const w=await worker();let intercepted=false;
  w.handlers.fetch({request:{url:w.scope+'preview.html',method:'GET',mode:'navigate'},respondWith:()=>intercepted=true});
  assert.equal(intercepted,false);
});
