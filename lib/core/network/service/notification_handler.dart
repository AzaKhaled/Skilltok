import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skilltok/core/network/service/notification_service.dart';
import 'package:skilltok/main.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      // sound: RawResourceAndroidNotificationSound('custom_sound'),
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> initFirebaseMessaging() async {
    await _createNotificationChannel();

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');

    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Notification response: ${response.payload}");
      },
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && navigatorKey.currentContext != null) {
        NotificationService.handleNotification(
          navigatorKey.currentContext!,
          message.data,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (navigatorKey.currentContext != null) {
        NotificationService.handleNotification(
          navigatorKey.currentContext!,
          message.data,
        );
      }
    });
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log("Foreground message received: ${message.messageId}");
    try {
      final RemoteNotification? notification = message.notification;
      if (notification == null) return;

      log("Title: ${notification.title}, Body: ${notification.body}");

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            // sound: RawResourceAndroidNotificationSound('custom_sound'),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // sound: 'custom_sound.caf',
          ),
        ),
      );

      if (navigatorKey.currentContext != null) {
        NotificationService.handleNotification(
          navigatorKey.currentContext!,
          message.data,
        );
      }
    } catch (e) {
      log("Error handling foreground message: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> messageHandler(RemoteMessage message) async {
    log('Background message received: ${message.messageId}');
  }
}
