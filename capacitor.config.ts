import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.easy.apk',
  appName: 'Easy APK',
  webDir: 'www',
  server: {
    url: 'https://royzoworld.ai1x.us.ci',   // <– your site
    cleartext: true,                  // keep if HTTP
    // 👇 This is the key line: catch all pages
    allowNavigation: ['royzoworld.ai1x.us.ci']  // only navigate inside your domain
  },
  android: {
    allowMixedContent: true
  }
};

export default config;