import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  //Initialize firebase messaging
  FirebaseMessaging message = FirebaseMessaging.instance;

  //Initialize Flutter local notification plugin
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin

  // NotificationSettings setting =
  NotificationService() {
    // const initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    // const initializationSettingsIOS = DarwinInitializationSettings();
    // const initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsIOS,
    // );
  }
  //Request permissions
  void requestNotificationPermission() async {
    NotificationSettings settings = await message.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);
  }

  void firebaseinit(context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? remoteNotification = message.notification;
      AndroidNotification? androidNotification = message.notification!.android;
      if (kDebugMode) {
        log("notifications title:${remoteNotification!.title}");
        log("notifications body:${remoteNotification.body}");
        log('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {
        // forgroundMessage();
      }

      if (Platform.isAndroid) {
        // showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async{
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification == null || android == null) {
      return;
    }
    return;
  }
}
