import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:auto_spare/services/user_store.dart';

final FirebaseMessaging _fcm = FirebaseMessaging.instance;

final FlutterLocalNotificationsPlugin _localNotifs =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotifications {
  PushNotifications._();

  static Future<void> initGlobal() async {
    await _initLocalNotifs();

    await _requestPermissions();

    _setupForegroundListener();
    _setupOnMessageOpenedApp();
  }

  static Future<void> syncTokenWithFirestore() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _saveTokenToFirestore(token);
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  static Future<void> _initLocalNotifs() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse r) {},
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'اشعارات مهمة',
      description: 'تُستخدم لإشعارات طلبات السحب والطلبات الهامة.',
      importance: Importance.high,
    );

    await _localNotifs
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = notification?.android;

      if (notification != null && android != null) {
        _showLocalNotification(
          title: notification.title ?? 'تنبيه جديد',
          body: notification.body ?? '',
        );
      }
    });
  }

  static void _setupOnMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'اشعارات مهمة',
      channelDescription: 'طلبات السحب والإشعارات المهمة الأخرى',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifs.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notifDetails,
    );
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    final user = UserStore().currentUser;
    if (user == null) {
      debugPrint('FCM: لا يوجد مستخدم حالياً، مش هنسجّل التوكن');
      return;
    }

    final db = FirebaseFirestore.instance;

    await db.collection('users').doc(user.id).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));

    if (user.towCompanyId != null && user.towCompanyId!.isNotEmpty) {
      await db.collection('tow_companies').doc(user.towCompanyId!).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    }

    debugPrint('FCM token saved for user ${user.id}');
  }
}
