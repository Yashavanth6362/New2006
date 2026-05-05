import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.royzo.app',
  appName: 'Royzo',
  webDir: 'www',
  server: {
    url: 'https://royzoworld.ai1x.us.ci',
    cleartext: true,
    allowNavigation: ['royzoworld.ai1x.us.ci']
  },
  android: {
    allowMixedContent: true,
    manifest: {
      'uses-permission': [
        // Normal (automatic)
        { 'android:name': 'android.permission.INTERNET' },
        { 'android:name': 'android.permission.ACCESS_NETWORK_STATE' },
        { 'android:name': 'android.permission.VIBRATE' },

        // Dangerous – will show after runtime request
        { 'android:name': 'android.permission.POST_NOTIFICATIONS' },
        { 'android:name': 'android.permission.CAMERA' },
        { 'android:name': 'android.permission.RECORD_AUDIO' },
        { 'android:name': 'android.permission.ACCESS_FINE_LOCATION' },
        { 'android:name': 'android.permission.ACCESS_COARSE_LOCATION' },

        // Storage (needed for file downloads, uploads)
        { 'android:name': 'android.permission.READ_EXTERNAL_STORAGE' },
        { 'android:name': 'android.permission.WRITE_EXTERNAL_STORAGE' },
        { 'android:name': 'android.permission.READ_MEDIA_IMAGES' },
        { 'android:name': 'android.permission.READ_MEDIA_VIDEO' },
        { 'android:name': 'android.permission.READ_MEDIA_AUDIO' },

        // Phone call (if your website uses tel: links)
        { 'android:name': 'android.permission.CALL_PHONE' }
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