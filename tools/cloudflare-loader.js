// Load the precompressed Godot WASM as a static asset, then expose a decoded
// application/wasm Response to Godot. This avoids CDN double-compression and
// Cloudflare's 25 MiB per-asset limit without using a Worker or paid storage.
(() => {
  const nativeFetch = window.fetch.bind(window);
  window.fetch = async (input, init) => {
    const url = new URL(typeof input === 'string' || input instanceof URL ? input : input.url, window.location.href);
    if (url.origin !== window.location.origin || !url.pathname.endsWith('/index.wasm')) return nativeFetch(input, init);
    const original = new Request(input, init);
    url.pathname += '.gz';
    const response = await nativeFetch(new Request(url, original));
    if (!response.ok) return response;
    if (typeof DecompressionStream === 'undefined') throw new Error('Trình duyệt cần được cập nhật để tải trò chơi.');
    const headers = new Headers(response.headers);
    headers.delete('content-encoding');
    headers.delete('content-length');
    headers.set('content-type', 'application/wasm');
    return new Response(response.body.pipeThrough(new DecompressionStream('gzip')), { status: 200, headers });
  };
})();
