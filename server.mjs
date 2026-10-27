// Development file server only. The application itself is entirely static.
import http from 'node:http';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
const root = process.cwd();
const mime = {'.html':'text/html','.js':'text/javascript','.css':'text/css','.svg':'image/svg+xml','.png':'image/png','.jpg':'image/jpeg','.json':'application/json','.webmanifest':'application/manifest+json'};
http.createServer(async(req,res) => {
  try {
    const name = decodeURIComponent(new URL(req.url,'http://localhost').pathname);
    const file = path.resolve(root,'.'+(name==='/'?'/index.html':name));
    if (!file.startsWith(root+path.sep)) { res.writeHead(403); return res.end(); }
    const data = await readFile(file); res.writeHead(200,{'Content-Type':mime[path.extname(file)]||'application/octet-stream','Cache-Control':'no-cache'}); res.end(data);
  } catch { res.writeHead(404); res.end('Not found'); }
}).listen(5173,'127.0.0.1',()=>console.log('Local: http://127.0.0.1:5173'));
