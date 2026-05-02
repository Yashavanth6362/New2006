import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.easy.apk',
  appName: 'Easy APK',
  webDir: 'www',
  server: {
    url: 'https://yourwebsite.com',   // <– your site
    cleartext: true,                  // keep if HTTP
    // 👇 This is the key line: catch all pages
    allowNavigation: ['yourwebsite.com']  // only navigate inside your domain
  },
  android: {
    allowMixedContent: true
  }
};

export default config;