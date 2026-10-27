import { spawnSync } from 'node:child_process';
import { copyFile, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = fileURLToPath(new URL('..', import.meta.url));
const cwd = path.join(root, 'flutter_app');
const result = process.platform === 'win32'
  ? spawnSync('cmd.exe', ['/d', '/c', 'flutter', 'build', 'apk', '--release'], { cwd, stdio: 'inherit' })
  : spawnSync('flutter', ['build', 'apk', '--release'], { cwd, stdio: 'inherit' });
if (result.error) throw result.error;
if (result.status !== 0) process.exit(result.status || 1);
await mkdir(path.join(root, 'artifacts'), { recursive: true });
const output = path.join(root, 'artifacts', 'Limpyo-Pisaan-Flutter.apk');
await copyFile(path.join(cwd, 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk'), output);
console.log(`Flutter Android APK: ${output}`);
