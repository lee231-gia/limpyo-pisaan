const BASE = self.registration.scope;
const PREFIX = `limpyo-pisaan:${new URL(BASE).pathname}:`;
const CACHE = `${PREFIX}v1`;
const SHELL = ['index.html','app.js','core.js','sample-data.js','pwa.js','styles.css','manifest.webmanifest','assets/logo.svg','assets/community.svg','assets/icon-192.png','assets/icon-512.png','assets/icon-maskable-512.png','assets/apple-touch-icon.png'];
const shellURL = new URL('index.html', BASE).href;

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(SHELL.map(file => new URL(file, BASE).href))).then(() => self.skipWaiting()));
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key.startsWith(PREFIX) && key !== CACHE).map(key => caches.delete(key)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET' || url.origin !== new URL(BASE).origin || !url.href.startsWith(BASE)) return;
  if (event.request.mode === 'navigate' && url.pathname !== new URL(BASE).pathname && url.pathname !== new URL(shellURL).pathname) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    const key = event.request.mode === 'navigate' ? shellURL : event.request;
    try {
      const response = await fetch(event.request);
      if (response.ok && response.type !== 'opaque') await cache.put(key, response.clone());
      return response;
    } catch {
      const cached = await cache.match(key);
      return cached || new Response('Unavailable offline. Open the app online once, then try again.', {status:503,headers:{'Content-Type':'text/plain'}});
    }
  })());
});
