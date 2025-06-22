// lib/services/notification_service.dart
import 'package:finance_tracker/core/constants/console.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // For handling notification when app is in foreground
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  NotificationService() {
    _initLocalNotifications();
    _initTimeZones();
  }

  void _initTimeZones() {
    tz.initializeTimeZones();
  }

  Future<void> initialize() async {
    // Request permission
    await _requestPermissions();

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    console("FCM Token: $token");
    // You should send this token to your backend server

    // Configure message handling
    _configureMessageHandling();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } else {
      // For Android
      await _firebaseMessaging.requestPermission();
    }
  }

  Future<void> _initLocalNotifications() async {
    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create high importance channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      print('Notification payload: ${response.payload}');
      // Navigate to appropriate screen based on payload
    }
  }

  void _configureMessageHandling() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users
      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: android.smallIcon ?? '@mipmap/launcher_icon',
              // Set other notification properties here
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: message.data['screen'] ?? '',
        );
      }
    });

    // Handle notification tap when app is in background but open
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigate to appropriate screen based on message data
      _handleNotificationNavigation(message.data);
    });

    // Check if app was opened from a notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification!');
        // Navigate to appropriate screen after a delay to ensure app is initialized
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationNavigation(message.data);
        });
      }
    });
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    String? screenName = data['screen'];
    String? itemId = data['id'];

    // Add asset/liability navigation cases
    switch (screenName) {
      case 'transaction_details':
        if (itemId != null) {
          print('Should navigate to transaction details for ID: $itemId');
        }
        break;
      case 'budget_alert':
        print('Should navigate to budget screen');
        break;
      case 'asset_details':
        if (itemId != null) {
          print('Should navigate to asset details for ID: $itemId');
        }
        break;
      case 'liability_details':
        if (itemId != null) {
          print('Should navigate to liability details for ID: $itemId');
        }
        break;
    }
  }

  // Subscribe to topics for segmented notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Add methods for asset/liability notifications
  Future<void> scheduleAssetLiabilityNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String itemId,
    required String type, // 'asset' or 'liability'
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'ASSET_LIABILITY_ALERT',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'screen': '${type}_details',
        'id': itemId,
      }),
    );
  }

  // Add method to send push notifications for assets/liabilities
  Future<void> sendAssetLiabilityPushNotification({
    required String title,
    required String body,
    required String topic,
    required String itemId,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await subscribeToTopic(topic);
      
      // In a real app, you would send this to your backend
      // which would then use Firebase Admin SDK to send the notification
      final message = {
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'screen': '${type}_details',
          'id': itemId,
          ...?additionalData,
        },
        'topic': topic,
      };
      
      console('Push notification payload: $message', type: DebugType.info);
    } catch (e) {
      console('Error sending push notification: $e', type: DebugType.error);
    }
  }
}
