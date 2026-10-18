// Static export preview only. Production is served by Firebase Hosting.
import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { resolve, sep, extname } from 'node:path';
const root = resolve('out');
const port = Number(process.env.GUARDIAN_PREVIEW_PORT ?? 3100);
if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('Invalid preview port.');
const types = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8', '.json': 'application/json', '.svg': 'image/svg+xml', '.ico': 'image/x-icon', '.png': 'image/png', '.woff2': 'font/woff2', '.txt': 'text/plain; charset=utf-8' };
createServer(async (request, response) => {
  try {
    const url = new URL(request.url ?? '/', 'http://127.0.0.1');
    let path = resolve(root, '.' + decodeURIComponent(url.pathname));
    if (path !== root && !path.startsWith(root + sep)) { response.writeHead(403); response.end(); return; }
    if ((await stat(path)).isDirectory()) path = resolve(path, 'index.html');
    const body = await readFile(path);
    response.writeHead(200, { 'Content-Type': types[extname(path)] ?? 'application/octet-stream', 'Cache-Control': 'no-store' }); response.end(body);
  } catch { response.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' }); response.end(await readFile(resolve(root, '404.html')).catch(() => 'Not found')); }
}).listen(port, '127.0.0.1', () => process.stdout.write(`Static dashboard preview: http://127.0.0.1:${port}\n`));
