import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:developer' as developer;
import 'package:flutter_project/app/pages/health_tips.dart'; // Import HealthTips
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize Notifications
  Future<void> init() async {
    await initialize();
  }

  /// Initialize the notification plugin
  Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/app_logo');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combine platform settings
      const InitializationSettings initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Create notification channels for Android
      const AndroidNotificationChannel instantChannel = AndroidNotificationChannel(
        'instant_channel',
        'Instant Notifications',
        description: 'Notifications shown immediately, like login success',
        importance: Importance.high,
      );

      const AndroidNotificationChannel healthTipsChannel = AndroidNotificationChannel(
        'health_tips_channel',
        'Health Tips',
        description: 'Get daily health tips to stay healthy',
        importance: Importance.high,
      );

      const AndroidNotificationChannel profileChannel = AndroidNotificationChannel(
        'profile_channel',
        'Profile Updates',
        description: 'Notifications for profile updates',
        importance: Importance.max,
      );

      // Create the channels on Android
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(instantChannel);
      await androidPlugin?.createNotificationChannel(healthTipsChannel);
      await androidPlugin?.createNotificationChannel(profileChannel);

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
      developer.log('NotificationService initialized successfully', name: 'NotificationService');

      // Request notification permissions for Android 13+
      if (Platform.isAndroid) {
        await androidPlugin?.requestNotificationsPermission();
      }
    } catch (e) {
      developer.log('Error initializing NotificationService: $e', name: 'NotificationService');
    }
  }

  /// Show an immediate notification (e.g., for login success)
  Future<void> showImmediateNotification() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'instant_channel',
        'Instant Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

      await _flutterLocalNotificationsPlugin.show(
        0,
        'Login Successful 🎉',
        'Welcome back! Stay healthy & active!',
        details,
      );

      developer.log('Instant notification displayed', name: 'NotificationService');
    } catch (e) {
      developer.log('Error showing immediate notification: $e', name: 'NotificationService');
    }
  }

  /// Schedule a notification at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'profile_channel',
        'Profile Updates',
        channelDescription: 'Notifications for profile updates',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      developer.log('Scheduled notification with ID $id at $scheduledTZDateTime', name: 'NotificationService');
    } catch (e) {
      developer.log('Error scheduling notification: $e', name: 'NotificationService');
    }
  }

  /// Send a health tip notification (called by the background service)
  Future<void> sendHealthTipNotification() async {
    try {
      final String tip = HealthTips.getRandomTip();
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'health_tips_channel',
        'Health Tips',
        channelDescription: 'Get daily health tips to stay healthy',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 1000,
        'Health Tip 🌟',
        tip,
        details,
      );

      developer.log('Sent Health Tip Notification: $tip', name: 'NotificationService');
    } catch (e) {
      developer.log('Error sending health tip notification: $e', name: 'NotificationService');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      developer.log('All notifications canceled', name: 'NotificationService');
    } catch (e) {
      developer.log('Error canceling notifications: $e', name: 'NotificationService');
    }
  }
}