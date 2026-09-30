const CACHE = 'vault-of-us-shell-v2';
const SHELL = ['/', '/manifest.webmanifest'];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key)))),
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin) return;
  if (url.pathname.startsWith('/api/') || url.pathname.startsWith('/storage/')) return;
  const isNavigation = request.mode === 'navigate';
  const isStaticAsset = /^\/(assets\/|icons\/|manifest\.webmanifest$)/.test(url.pathname) && !url.search;
  if (!isNavigation && !isStaticAsset) return;
  event.respondWith(
    fetch(request).then((response) => {
      if (response.ok && response.type === 'basic' && (isStaticAsset || (isNavigation && !url.search))) {
        const copy = response.clone();
        caches.open(CACHE).then((cache) => cache.put(isNavigation ? '/' : request, copy));
      }
      return response;
    }).catch(async () => (await caches.match(isNavigation ? '/' : request)) || caches.match('/')),
  );
});

self.addEventListener('push', (event) => {
  event.waitUntil(self.registration.showNotification('Vault of Us', {
    body: 'Você recebeu uma mensagem.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'vault-message',
    data: { url: '/#chat' },
  }));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const target = new URL('/#chat', self.location.origin).href;
  event.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
    for (const client of clients) {
      if (client.url.startsWith(self.location.origin) && 'focus' in client) {
        client.postMessage({ type: 'open-chat' });
        return client.focus();
      }
    }
    return self.clients.openWindow(target);
  }));
});
