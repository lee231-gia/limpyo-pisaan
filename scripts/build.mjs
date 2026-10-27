import { mkdir, cp, copyFile, writeFile, rm } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = fileURLToPath(new URL('..', import.meta.url));
const output = path.resolve(root, 'dist');
// Keep cleanup confined to this project's generated output directory.
if (path.dirname(output) !== path.resolve(root) || path.basename(output) !== 'dist') throw new Error('Unsafe output directory');
await rm(output, { recursive: true, force: true });
await mkdir(output, { recursive: true });
const files = ['index.html','app.js','core.js','sample-data.js','pwa.js','styles.css','sw.js','manifest.webmanifest'];
for (const file of files) await copyFile(path.join(root,file), path.join(output,file));
await cp(path.join(root,'assets'), path.join(output,'assets'), { recursive: true });
await writeFile(path.join(output,'.nojekyll'),'');
console.log('Mobile app built in dist/ — ready for static hosting and GitHub Pages.');
