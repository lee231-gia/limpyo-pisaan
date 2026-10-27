import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import vm from 'node:vm';

test('Android embeds bundled frontend assets without a remote server URL',async()=>{
  const config=JSON.parse(await readFile(new URL('../capacitor.config.json',import.meta.url),'utf8'));
  assert.equal(config.appId,'com.limpyopisaan.app');
  assert.equal(config.webDir,'dist');
  assert.equal(config.server?.url,undefined);
});
test('native Android reports itself installed and does not register a web service worker',async()=>{
  const listeners=[];
  const context=vm.createContext({window:{Capacitor:{isNativePlatform:()=>true},isSecureContext:true,addEventListener:(type)=>listeners.push(type)},navigator:{serviceWorker:{}}});
  const source=await readFile(new URL('../pwa.js',import.meta.url),'utf8');
  vm.runInContext(source.replaceAll('export ','')+'\nglobalThis.result=installState();',context);
  assert.equal(context.result.native,true);
  assert.equal(context.result.installed,true);
  assert.equal(listeners.includes('load'),false);
});
