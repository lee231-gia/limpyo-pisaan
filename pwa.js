let installPrompt = null;
const nativeApp = window.Capacitor?.isNativePlatform?.() === true;

window.addEventListener('beforeinstallprompt', event => {
  event.preventDefault();
  installPrompt = event;
});
window.addEventListener('appinstalled', () => { installPrompt = null; });

export function installState() {
  return {
    native: nativeApp,
    installed: nativeApp || window.matchMedia('(display-mode: standalone)').matches || navigator.standalone === true,
    canPrompt: installPrompt !== null
  };
}

export async function installApp() {
  if (!installPrompt) return 'unavailable';
  const prompt = installPrompt;
  installPrompt = null;
  try {
    await prompt.prompt();
    return (await prompt.userChoice).outcome;
  } catch { return 'unavailable'; }
}

// Relative URL and scope also work at https://USERNAME.github.io/REPOSITORY/.
if (!nativeApp && 'serviceWorker' in navigator && window.isSecureContext) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js', {scope:'./', updateViaCache:'none'})
      .catch(() => { /* Online functionality remains available when offline setup is blocked. */ });
  });
}
