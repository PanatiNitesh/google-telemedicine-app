import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:developer' as developer;
import 'health_tips.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ✅ **Added the init method**
  Future<void> init() async {
    await initialize();
  }

  /// ✅ *Initialize Notifications*
  Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/app_logo');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showImmediateNotification() async {
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
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void scheduleHealthTipsNotification() {
    Timer.periodic(const Duration(minutes: 2), (timer) {
      sendHealthTipNotification();
    });

    developer.log('Health tips notifications scheduled every 2 minutes',
        name: 'NotificationService');
  }

  Future<void> sendHealthTipNotification() async {
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
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    developer.log('All notifications canceled', name: 'NotificationService');
  }
}