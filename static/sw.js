// Self-destroying service worker.
//
// The previous Jekyll/Chirpy site registered a PWA service worker at this same
// path (/sw.js). Service workers persist in the browser across deploys, so old
// visitors still have Chirpy's worker running — intercepting requests and
// erroring on a Google Analytics fetch. This replacement unregisters itself and
// clears the old caches the next time the browser checks /sw.js for an update.
self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      // Drop every cache the old worker created.
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
      // Unregister this worker.
      await self.registration.unregister();
      // Reload open tabs so they run without any service worker.
      const clients = await self.clients.matchAll({ type: 'window' });
      clients.forEach((client) => client.navigate(client.url));
    })()
  );
});
