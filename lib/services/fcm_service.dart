import 'dart:convert';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/main.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/icon_main');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          navigatorKey.currentState?.pushNamed('/notifications');
        },
      );

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _sendTokenToServer(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        navigatorKey.currentState?.pushNamed('/notifications');
      });

      _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
           Future.delayed(const Duration(seconds: 1), () {
             navigatorKey.currentState?.pushNamed('/notifications');
           });
        }
      });
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      final userToken = await SecureStorage.getToken();
      if (userToken == null || userToken.isEmpty) {
        return;
      }

      final apiService = ApiService();
      await apiService.post(
        ApiConfig.updateDeviceToken,
        data: {'fcm_token': token},
      );
    } catch (e) {}
  }

  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    const Color brandColor = Color(0xFF009688);

    if (notification != null && android != null) {
      final BigTextStyleInformation bigTextStyleInformation =
          BigTextStyleInformation(
        notification.body ?? '',
        htmlFormatBigText: true,
        contentTitle: notification.title,
        htmlFormatContentTitle: true,
        summaryText: 'Gia Sư App',
        htmlFormatSummaryText: true,
      );

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel',
            'Thông báo chính',
            channelDescription: 'Nhận thông báo quan trọng từ ứng dụng',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/icon_main',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/icon_main'),
            color: brandColor,
            styleInformation: bigTextStyleInformation,
            playSound: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }
}