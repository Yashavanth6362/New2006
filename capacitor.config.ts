import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.royzo.app',
  appName: 'Royzo',
  webDir: 'www',
  // ❗ No server.url → the app loads the local www/index.html first
  android: {
    allowMixedContent: true,
    manifest: {
      'uses-permission': [
        { 'android:name': 'android.permission.INTERNET' },
        { 'android:name': 'android.permission.POST_NOTIFICATIONS' },
        { 'android:name': 'android.permission.READ_EXTERNAL_STORAGE' },
        { 'android:name': 'android.permission.WRITE_EXTERNAL_STORAGE' },
        { 'android:name': 'android.permission.READ_MEDIA_IMAGES' },
        { 'android:name': 'android.permission.READ_MEDIA_VIDEO' },
        { 'android:name': 'android.permission.READ_MEDIA_AUDIO' },
        { 'android:name': 'android.permission.CAMERA' },
        { 'android:name': 'android.permission.RECORD_AUDIO' },
        { 'android:name': 'android.permission.ACCESS_FINE_LOCATION' },
        { 'android:name': 'android.permission.ACCESS_COARSE_LOCATION' }
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