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
        log('Notification or Android notification is null');
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

  String key =
      "nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDVi9ZAhBWD2Nh0\n49oRkMMWUXE9RT6HucPM2AGdE+xdKBDVFDLJkjGCeJaIpqTio4VKO2eCFEvdhFr6\nwkDGXyD32N9Gq9Src4sXykVGAM+bqmfheNQOELQ9oNXcZmPlO8rQcOdSVKP3sWnG\nal5SEYpnuGSkSfDmQp3DW3ka2PpkAOmaEX8IHNM8knZGRmiIienO+4fXp65ebp2Z\nVIztaDP0pb6VDzv+cUmoeelNwg4967bvdK3nfLFdT+Ehlipd2EG7zOLQPwAnUQYY\nGZQboUH3No/q384/hY4uD+iYNifMk+tkqKvwy77Mg9qcB0Z68BJSt3v4/U/JA5ok\nZhjpj/KlAgMBAAECggEALxAUBoD1quqh/dTvjPp9/E+zqMC3gLsgm2cpp+Apsfgw\nCX3bmZAGKE6CQpiTcz19lTgVXlYxyB6w3F3uX6m8ftMFljIteyHKUFJsRPrNxm1e\nWpNCDN2Ck6h8KYhJUM6GKr0PRhZQUrj/alKr+eNSwPwi9hAzrtOUqGbjAFc8i8g+\nm4u7VURT6C/GSlWTazJPZsHDZJM+zPFJnTrCV/WvcZiFiGSrlB3OaxKjCUTvIiNB\nJwLgxvhhayPrFumCV1zzPYg1vX85jVkpQwVpRP4HtP2nfzKTNuuiHF8HEPzv0+i0\nqkBowfuhRZZ5oNoUQy60uCLL1ZuY0P8tfwkXQqSh4QKBgQDv6S8Q/gpBK6BR7aIu\nN+oe140nvGcl4pAnVjq3QYN7l4Zw2Gh+ftDAA4yWNDkhU59000uBvsmik0eoOiDp\nQgWlIcQMfTLEpUEXkEHV3SpCktOU/qy8MKoX2gNfF5PgT+BIg2G4mElb/1TnrdPt\nMjAybd3iMa0Ll9DfEAIXjNJ5FQKBgQDj3gWorhS2TZqVrE+m8SPBxDbMZUHWjAOj\nNeGBd/X+gJ/hwObLzkfKtASsoqiwYrxuBqSgI+S0kEfUmw5TQG+RHeCLkZso6f5N\nlR15V74+2nfMKO4pB1qP6cWh5kzQ9YJutZ78l0FOkL+MXQbL/+mOC9WNHcYJUcjG\nggyH7evXUQKBgDvqIV3+A7OY4JX1Yc5nGmoPbOoijCQS++tHBqzjiKGiCuo9sYL9\nysZZXI/ahPYEu0rixfWmHxch7wBdXADFA0HlN9/imH4xwxrOZRKzBC3SG1MXcy4g\nfSotwS/LZJvddubFIO+H4LJABwVBDS8snIrLk2E9BLljdb9vcQZOnfWtAoGBAMkO\ng+u7/iaE/tsFuRpSNvynhrp+tcL6s9L0nc9A69rt3ySwsnQtxQbEJEO3GiTYWe6z\nCdsLEKeJjve3AMLQXiCrPg+oIEHPhUUrR2Bj3UdUONP5YXruNCg7Wthpfmn51mac\n9nVleIg8C+drxa2GVquxIXJsTOq4MPGGmkvt0GShAoGBAIr2mRRNMTqNeDgIqO7n\nnSc5kYF3D3116zbiPjwNGMeHVTF7AJVUsAMb0HFTWa29Hec4MJ6HomXGQNrWGB8I\nXlBsQ5hwxyl5E700FThD/DnRZRwc2DqUN1YvyOYEd5aVNm7hR7nqxgJDtmyQ48bB\nsTrQ19/MhAY+xgWpxcHk2OjZ";

  Future sendNotification(String fcmToken, String messageText, String senderId,
      String otherUserId, String chatRoomId) async {
    final serverKey =
        '5655152e057da702dd62cccd64ec436a303721ec'; // Get from Firebase Console
    const url = 'https://fcm.googleapis.com/fcm/send';

    final responae = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDVi9ZAhBWD2Nh0\n49oRkMMWUXE9RT6HucPM2AGdE+xdKBDVFDLJkjGCeJaIpqTio4VKO2eCFEvdhFr6\nwkDGXyD32N9Gq9Src4sXykVGAM+bqmfheNQOELQ9oNXcZmPlO8rQcOdSVKP3sWnG\nal5SEYpnuGSkSfDmQp3DW3ka2PpkAOmaEX8IHNM8knZGRmiIienO+4fXp65ebp2Z\nVIztaDP0pb6VDzv+cUmoeelNwg4967bvdK3nfLFdT+Ehlipd2EG7zOLQPwAnUQYY\nGZQboUH3No/q384/hY4uD+iYNifMk+tkqKvwy77Mg9qcB0Z68BJSt3v4/U/JA5ok\nZhjpj/KlAgMBAAECggEALxAUBoD1quqh/dTvjPp9/E+zqMC3gLsgm2cpp+Apsfgw\nCX3bmZAGKE6CQpiTcz19lTgVXlYxyB6w3F3uX6m8ftMFljIteyHKUFJsRPrNxm1e\nWpNCDN2Ck6h8KYhJUM6GKr0PRhZQUrj/alKr+eNSwPwi9hAzrtOUqGbjAFc8i8g+\nm4u7VURT6C/GSlWTazJPZsHDZJM+zPFJnTrCV/WvcZiFiGSrlB3OaxKjCUTvIiNB\nJwLgxvhhayPrFumCV1zzPYg1vX85jVkpQwVpRP4HtP2nfzKTNuuiHF8HEPzv0+i0\nqkBowfuhRZZ5oNoUQy60uCLL1ZuY0P8tfwkXQqSh4QKBgQDv6S8Q/gpBK6BR7aIu\nN+oe140nvGcl4pAnVjq3QYN7l4Zw2Gh+ftDAA4yWNDkhU59000uBvsmik0eoOiDp\nQgWlIcQMfTLEpUEXkEHV3SpCktOU/qy8MKoX2gNfF5PgT+BIg2G4mElb/1TnrdPt\nMjAybd3iMa0Ll9DfEAIXjNJ5FQKBgQDj3gWorhS2TZqVrE+m8SPBxDbMZUHWjAOj\nNeGBd/X+gJ/hwObLzkfKtASsoqiwYrxuBqSgI+S0kEfUmw5TQG+RHeCLkZso6f5N\nlR15V74+2nfMKO4pB1qP6cWh5kzQ9YJutZ78l0FOkL+MXQbL/+mOC9WNHcYJUcjG\nggyH7evXUQKBgDvqIV3+A7OY4JX1Yc5nGmoPbOoijCQS++tHBqzjiKGiCuo9sYL9\nysZZXI/ahPYEu0rixfWmHxch7wBdXADFA0HlN9/imH4xwxrOZRKzBC3SG1MXcy4g\nfSotwS/LZJvddubFIO+H4LJABwVBDS8snIrLk2E9BLljdb9vcQZOnfWtAoGBAMkO\ng+u7/iaE/tsFuRpSNvynhrp+tcL6s9L0nc9A69rt3ySwsnQtxQbEJEO3GiTYWe6z\nCdsLEKeJjve3AMLQXiCrPg+oIEHPhUUrR2Bj3UdUONP5YXruNCg7Wthpfmn51mac\n9nVleIg8C+drxa2GVquxIXJsTOq4MPGGmkvt0GShAoGBAIr2mRRNMTqNeDgIqO7n\nnSc5kYF3D3116zbiPjwNGMeHVTF7AJVUsAMb0HFTWa29Hec4MJ6HomXGQNrWGB8I\nXlBsQ5hwxyl5E700FThD/DnRZRwc2DqUN1YvyOYEd5aVNm7hR7nqxgJDtmyQ48bB\nsTrQ19/MhAY+xgWpxcHk2OjZ\n',
      },
      body: jsonEncode({
        "to": fcmToken,
        "notification": {
          "title": "New Message",
          "body": messageText,
          "sound": "default",
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "chatRoomId": chatRoomId,
          "otherUserId": otherUserId,
          "senderId": senderId,
          "message": messageText,
        },
        "priority": "high",
      }),
    );
  }
}
