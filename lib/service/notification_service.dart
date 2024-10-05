import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
// import 'package:uptourism_app/app.dart';
// import 'package:uptourism_app/utils/common_functions.dart';


class NotificationServices {
  // Base URL for images
  // final String baseUrl = AppConfig.instance.baseUrl;

  // Initialise Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialise Flutter Local Notifications Plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationServices() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          handleMessage(jsonDecode(response.payload!));
        }
      },
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (kDebugMode) {
        log("notifications title:${notification?.title}");
        log("notifications body:${notification?.body}");
        log('count:${android?.count}');
        log('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        showNotification(message);
      }
    });
  }

  // Request notification permission
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
       log('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        log('user granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        log('user denied permission');
      }
    }
  }

  Future<void> showNotification(RemoteMessage message,
      {bool isBackground = false}) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidNotification = notification?.android;

    if (notification == null || androidNotification == null) {
      if (kDebugMode) {
      log(
            'Notification or Android notification is null');
      }
      return;
    }

    String? imageUrl = message.data['image'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // imageUrl = Uri.parse(baseUrl).resolve(imageUrl).toString();
    }

    ByteArrayAndroidBitmap? bigPicture;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          bigPicture = ByteArrayAndroidBitmap.fromBase64String(
            base64Encode(response.bodyBytes),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          log('Failed to load image: $e');
        }
      }
    }

    BigPictureStyleInformation? bigPictureStyleInformation;
    if (bigPicture != null) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        bigPicture,
        contentTitle: '<b>${notification.title}</b>',
        htmlFormatContentTitle: true,
        summaryText: notification.body,
        htmlFormatContent: true,
        htmlFormatSummaryText: true,
      );
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotification.channelId ?? 'default_channel_id',
      androidNotification.channelId ?? 'default_channel_name',
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      styleInformation: bigPictureStyleInformation ??
          BigTextStyleInformation(
            notification.body ?? '',
            htmlFormatBigText: true,
            contentTitle: notification.title ?? '',
            htmlFormatContentTitle: true,
          ),
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );

    if (isBackground) {
      handleMessage(message.data);
    }
  }

  // Get device token
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  // Check if token needs refresh
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        log('refresh');
      }
    });
  }

  Future<void> setupInteractMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage.data);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(event.data);
    });
  }

  void handleMessage(Map<String, dynamic> messageData) {
    if (kDebugMode) {
     log('Message data: $messageData');
    }

    String? messageType = messageData['type'];
    String? id = messageData['id'];

    if (id == null) {
      if (kDebugMode) {
        // CommonFunctions.printLog('Invalid message type or id is null');
      }
      return;
    }

    // switch (messageType) {
    //   case 'place':
    //     rootNavigatorKey.currentState?.context
    //         .goNamed(RoutesConstant.placeDetailName, queryParameters: {
    //       "id": id,
    //     });
    //     break;
    //   case 'event':
    //     rootNavigatorKey.currentState?.context
    //         .goNamed(RoutesConstant.eventDetailRouteName, extra: {
    //       "id": id,
    //     });
    //     break;
    //   case 'city':
    //     rootNavigatorKey.currentState?.context
    //         .goNamed(RoutesConstant.cityDetailRouteName, extra: {
    //       "id": id,
    //     });
    //     break;
    //   default:
    //     if (kDebugMode) {
    //       log('Unhandled message type: $messageType');
    //     }
    //     break;
    // }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void handleSocialTap(String type, String id) {
    switch (type) {
      case '1':
        break;
      case '2':
        break;

      default:
        break;
    }
  }
}