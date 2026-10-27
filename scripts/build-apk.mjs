import { spawnSync } from 'node:child_process';
import { mkdir, copyFile, access, writeFile } from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('..', import.meta.url));
const android = path.join(root,'android');
const env = {...process.env};
const sdk = env.ANDROID_HOME || env.ANDROID_SDK_ROOT || (process.platform==='win32' ? path.join(os.homedir(),'AppData','Local','Android','Sdk') : null);
if (sdk) {
  await access(sdk);
  env.ANDROID_HOME=sdk;
  await writeFile(path.join(android,'local.properties'),`sdk.dir=${sdk.replaceAll('\\','/')}\n`);
}
function run(command,args,cwd=root) {
  const result=spawnSync(command,args,{cwd,env,stdio:'inherit'});
  if(result.error)throw result.error;
  if(result.status!==0)process.exit(result.status||1);
}
run(process.execPath,['scripts/build.mjs']);
run(process.execPath,['node_modules/@capacitor/cli/bin/capacitor','sync','android']);
if(process.platform==='win32')run('cmd.exe',['/d','/c','gradlew.bat','assembleDebug','--no-daemon'],android);
else run('sh',['./gradlew','assembleDebug','--no-daemon'],android);
await mkdir(path.join(root,'artifacts'),{recursive:true});
const output=path.join(root,'artifacts','Limpyo-Pisaan.apk');
await copyFile(path.join(android,'app','build','outputs','apk','debug','app-debug.apk'),output);
console.log(`\nInstallable debug APK: ${output}`);
