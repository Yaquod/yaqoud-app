import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'yaqood_high_importance_channel',
    'Yaqood Trip Updates',
    description: 'This channel is used for important trip notifications.',
    importance: Importance.max,
    playSound: true,
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(initSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void startForegroundListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // String? status = message.data['status']; 
      String title = message.notification?.title ?? "";
      String body = message.notification?.body ?? "";
      print("----------------------------------");
      print("title: $title");
      print("body: $body");
      print("----------------------------------");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: title,
        desc: body,
        btnOkOnPress: () {

        },
      ).show();
    });
  }

  Future<String?> getDeviceToken() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return await _messaging.getToken();
    }

    return null;
  }
}
