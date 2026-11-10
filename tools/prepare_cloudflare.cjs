// Prepare a static Cloudflare Pages release, with every asset below 25 MiB.
// Node built-ins only. The original Godot export is left untouched.
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const crypto = require('node:crypto');
const [source, destination] = process.argv.slice(2);
if (!source || !destination) throw new Error('Usage: node prepare_cloudflare.cjs EXPORT_DIR PAGES_DIR');
const src = path.resolve(source), dest = path.resolve(destination);
if (src === dest || dest.startsWith(src + path.sep)) throw new Error('Use a separate destination directory');
fs.mkdirSync(dest, { recursive: true });
const staleWasm = path.join(dest, "index.wasm");
if (fs.existsSync(staleWasm)) fs.unlinkSync(staleWasm);
const allowed = /^(index\.(html|js|wasm|pck|png|icon\.png|apple-touch-icon\.png|audio\.worklet\.js)|FONT-LICENSE\.txt)$/;
const report = [];
for (const entry of fs.readdirSync(src)) {
  if (!allowed.test(entry)) continue;
  const original = fs.readFileSync(path.join(src, entry));
  let output = original;
  if (entry === 'index.wasm') {
    output = zlib.gzipSync(original, { level: 9 });
    if (!zlib.gunzipSync(output).equals(original)) throw new Error('WASM compression round-trip failed');
  }
  if (output.length > 25 * 1024 * 1024) throw new Error(`${entry} exceeds the 25 MiB free static asset limit`);
  fs.writeFileSync(path.join(dest, entry === "index.wasm" ? "index.wasm.gz" : entry), output);
  report.push({ file: entry, original: original.length, uploaded: output.length, sha256: crypto.createHash('sha256').update(output).digest('hex') });
}
for (const required of ['index.html','index.js','index.wasm','index.pck']) {
  if (!report.some(row => row.file === required)) throw new Error(`Missing ${required}`);
}
fs.copyFileSync(path.join(__dirname, 'cloudflare-loader.js'), path.join(dest, 'cloudflare-loader.js'));
const htmlPath = path.join(dest, 'index.html');
const html = fs.readFileSync(htmlPath, 'utf8');
fs.writeFileSync(htmlPath, html.replace('</head>', '<script src="cloudflare-loader.js"></script>\n</head>'));
const oldRedirects = path.join(dest, '_redirects');
if (fs.existsSync(oldRedirects)) fs.unlinkSync(oldRedirects);
fs.writeFileSync(path.join(dest, '_headers'), `/index.wasm.gz\n  Content-Type: application/gzip\n  Cache-Control: public, max-age=0, must-revalidate, no-transform\n\n/index.html\n  Cache-Control: no-cache\n\n/index.js\n  Cache-Control: no-cache\n\n/cloudflare-loader.js\n  Cache-Control: no-cache\n\n/index.pck\n  Cache-Control: no-cache\n`);
console.log(JSON.stringify({ files: report, hosting: 'Cloudflare Pages static only, no Functions, no R2 or paid resources' }, null, 2));
