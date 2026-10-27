import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile, access } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';

test('manifest launches standalone within a GitHub repository subpath', async () => {
  const manifest = JSON.parse(await readFile(new URL('../manifest.webmanifest', import.meta.url), 'utf8'));
  const base = 'https://example.github.io/limpyo-pisaan/';
  assert.equal(manifest.display, 'standalone');
  assert.equal(new URL(manifest.start_url, base).href, base);
  assert.equal(new URL(manifest.scope, base).href, base);
  for (const size of [192,512]) {
    const entry=manifest.icons.find(i=>i.sizes===`${size}x${size}` && i.purpose==='any');
    assert.ok(entry, `Install icon ${size} must exist`);
    const bytes=await readFile(new URL('../'+entry.src,import.meta.url));
    assert.equal(bytes.readUInt32BE(16),size);
    assert.equal(bytes.readUInt32BE(20),size);
  }
});

test('production build contains the complete app and excludes development and source documents', async () => {
  execFileSync(process.execPath,['scripts/build.mjs'],{cwd:new URL('..',import.meta.url),stdio:'pipe'});
  for (const name of ['index.html','app.js','core.js','sample-data.js','pwa.js','styles.css','sw.js','manifest.webmanifest','assets/icon-512.png','.nojekyll']) {
    await access(new URL('../dist/'+name,import.meta.url));
  }
  for (const name of ['server.mjs','tests','references','.git','README.md']) {
    await assert.rejects(access(new URL('../dist/'+name,import.meta.url)));
  }
});
