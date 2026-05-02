import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.easy.apk',
  appName: 'royzo',
  webDir: 'www',
  server: {
    url: 'https://royzoworld.ai1x.us.ci',
    cleartext: true,
    allowNavigation: ['royzoworld.ai1x.us.ci']
  },
  android: {
    allowMixedContent: true,
    // 👇 Add these manifest permissions
    manifest: {
      'uses-permission': [
        { 'android:name': 'android.permission.INTERNET' },
        { 'android:name': 'android.permission.POST_NOTIFICATIONS' },
        { 'android:name': 'android.permission.READ_EXTERNAL_STORAGE' },
        { 'android:name': 'android.permission.WRITE_EXTERNAL_STORAGE' },
        { 'android:name': 'android.permission.READ_MEDIA_IMAGES' },
        { 'android:name': 'android.permission.READ_MEDIA_VIDEO' },
        { 'android:name': 'android.permission.READ_MEDIA_AUDIO' }
      ],
      'application': [
        {
          'android:requestLegacyExternalStorage': 'true'
        }
      ]
    }
  }
};

export default config;