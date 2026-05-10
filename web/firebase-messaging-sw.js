// Service worker for FCM background messages on web.
// Loaded automatically by firebase_messaging from /firebase-messaging-sw.js.
// Updates here only take effect after a hard reload because browsers
// aggressively cache service workers.

importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

// Mirror of lib/core/firebase_options.dart (web). Update both together if
// the project is migrated.
firebase.initializeApp({
  apiKey: 'AIzaSyBgBiEqPuqEZAod-NgwWhYNLb_F94FTMTc',
  appId: '1:524259812223:web:988572878c88acbe52304a',
  messagingSenderId: '524259812223',
  projectId: 'teamup-ea2b9',
  authDomain: 'teamup-ea2b9.firebaseapp.com',
  storageBucket: 'teamup-ea2b9.firebasestorage.app',
});

const messaging = firebase.messaging();

// Background handler — fires when the page is closed/hidden. The default
// SDK behaviour (showing a notification when a `notification` payload is
// present) is what we want here, so we only override to customise look.
messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || 'TeamUp';
  const body = payload.notification?.body || '';
  self.registration.showNotification(title, {
    body,
    icon: '/icons/Icon-192.png',
    data: payload.data || {},
  });
});
