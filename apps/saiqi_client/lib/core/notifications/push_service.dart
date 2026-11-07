import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../repositories/auth_repository.dart';

/// Gestionnaire d'arrière-plan FCM (doit être une fonction de premier niveau).
@pragma('vm:entry-point')
Future<void> saiqiFirebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase non configuré : on ignore
  }
}

/// Push FCM : permission, enregistrement du token dans `profiles.fcm_token`, affichage au premier plan,
/// ouverture de l'écran concerné au tap. Si Firebase n'est pas configuré (pas de google-services.json),
/// le service se désactive silencieusement et l'app continue de fonctionner.
class PushService {
  PushService(this._auth);
  final AuthRepository _auth;

  static const channelId = 'saiqi_default';

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final List<StreamSubscription<dynamic>> _subs = [];
  bool _started = false;
  bool _firebaseOk = false;
  String? _token;

  /// Appelé avec le champ `data` de la notification (`screen`, `booking_id`, …).
  void Function(Map<String, dynamic> data)? onOpen;

  bool get isAvailable => _firebaseOk;

  Future<void> start({String channelName = 'SAIQI'}) async {
    if (_started || kIsWeb) return;
    _started = true;

    try {
      await Firebase.initializeApp();
      _firebaseOk = true;
    } catch (e) {
      debugPrint('Push désactivé (Firebase non configuré) : $e');
      _started = false;
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(saiqiFirebaseBackgroundHandler);
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (r) {
          final payload = r.payload;
          if (payload == null || payload.isEmpty) return;
          try {
            onOpen?.call(Map<String, dynamic>.from(jsonDecode(payload) as Map));
          } catch (_) {}
        },
      );
      final android = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.createNotificationChannel(
        AndroidNotificationChannel(channelId, channelName, importance: Importance.high),
      );

      // ignore: deprecated_member_use
      _token = await messaging.getToken();
      if (_token != null) await _auth.setFcmToken(_token);
      // ignore: deprecated_member_use
      _subs.add(messaging.onTokenRefresh.listen((t) {
        _token = t;
        unawaited(_auth.setFcmToken(t).catchError((_) {}));
      }));

      // Premier plan : FCM n'affiche rien, on affiche une notification locale.
      _subs.add(FirebaseMessaging.onMessage.listen((m) {
        final n = m.notification;
        if (n == null) return;
        unawaited(_local.show(
          id: m.hashCode,
          title: n.title,
          body: n.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: jsonEncode(m.data),
        ));
      }));

      // Arrière-plan -> tap, et application lancée depuis une notification.
      _subs.add(FirebaseMessaging.onMessageOpenedApp.listen((m) => onOpen?.call(m.data)));
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        Future<void>.delayed(const Duration(milliseconds: 600), () => onOpen?.call(initial.data));
      }
    } catch (e) {
      debugPrint('Initialisation push partielle : $e');
    }
  }

  /// À la déconnexion : le token est retiré du profil pour ne plus recevoir les notifications de ce compte.
  Future<void> unregister() async {
    if (_firebaseOk) {
      try {
        await _auth.setFcmToken(null);
        // ignore: deprecated_member_use
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
    }
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _started = false;
    _token = null;
  }
}
