import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/firebase/firestore.dart';

final _log = Logger();

/// Manages FCM permissions and per-device tokens. The server sends pushes
/// based on tokens stored on the user document; this service is the
/// client side that registers and revokes them.
///
/// Foreground messages are handled by the in-app `NotificationToastListener`
/// (it watches the Firestore `notifications` collection directly), so this
/// service just needs to keep the token list current.
class PushService {
  PushService({FirebaseMessaging? messaging, FirebaseFirestore? firestore})
      : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? db;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  StreamSubscription<String>? _refreshSub;
  String? _currentToken;
  String? _currentUserId;

  /// Web requires a VAPID key to issue tokens. Set via `--dart-define=
  /// FCM_VAPID_KEY=...` at build/run time. Without it, web token issuance
  /// fails silently and we just skip push registration.
  static const _webVapidKey = String.fromEnvironment('FCM_VAPID_KEY');

  /// Request permission and start tracking the device token for [userId].
  /// Idempotent — calling again with the same userId is a no-op; with a
  /// different userId it switches subscription.
  Future<void> register(String userId) async {
    if (_currentUserId == userId) return;
    if (_currentUserId != null) {
      await unregister(_currentUserId!);
    }
    _currentUserId = userId;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _log.i('FCM permission denied');
        return;
      }

      final token = await _getToken();
      if (token == null) {
        _log.w('FCM returned no token (likely missing VAPID key on web)');
        return;
      }
      _currentToken = token;
      await _addTokenToUser(userId, token);

      _refreshSub?.cancel();
      _refreshSub = _messaging.onTokenRefresh.listen((newToken) async {
        try {
          if (_currentToken != null && _currentToken != newToken) {
            await _removeTokenFromUser(userId, _currentToken!);
          }
          _currentToken = newToken;
          await _addTokenToUser(userId, newToken);
        } catch (e, st) {
          _log.e('FCM token refresh handler failed', error: e, stackTrace: st);
        }
      });
    } catch (e, st) {
      _log.e('FCM registration failed', error: e, stackTrace: st);
    }
  }

  /// Stop tracking and remove the current device's token from the user doc.
  Future<void> unregister(String userId) async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    final token = _currentToken;
    _currentToken = null;
    _currentUserId = null;
    if (token != null) {
      try {
        await _removeTokenFromUser(userId, token);
      } catch (e, st) {
        _log.w('Failed to remove FCM token on unregister', error: e, stackTrace: st);
      }
    }
  }

  Future<String?> _getToken() {
    if (kIsWeb) {
      if (_webVapidKey.isEmpty) return Future.value(null);
      return _messaging.getToken(vapidKey: _webVapidKey);
    }
    return _messaging.getToken();
  }

  Future<void> _addTokenToUser(String userId, String token) {
    return _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<void> _removeTokenFromUser(String userId, String token) {
    return _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}
