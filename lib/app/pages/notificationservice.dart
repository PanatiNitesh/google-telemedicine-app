import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'health_tips_channel',
      'Health Tips',
      description: 'Daily health tips notifications',
      importance: Importance.high,
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log('Notification tapped: ${response.payload}', name: 'NotificationService');
      },
    );

    if (await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ==
        false) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    developer.log('NotificationService initialized', name: 'NotificationService');
  }

  Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
  int retries = 3,
}) async {
  for (int attempt = 1; attempt <= retries; attempt++) {
    try {
      final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (scheduledTZDateTime.isBefore(now) || scheduledTZDateTime.isAtSameMomentAs(now)) {
        throw Exception(
          'Scheduled date must be in the future. Current time: $now, Scheduled time: $scheduledTZDateTime',
        );
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'health_tips_channel',
            'Health Tips',
            channelDescription: 'Daily health tips notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
      developer.log('Scheduled notification with id: $id, title: $title at $scheduledTZDateTime', name: 'NotificationService');
      return; // Success, exit the loop
    } catch (e) {
      if (attempt == retries) {
        developer.log('Failed to schedule notification after $retries attempts: $e', name: 'NotificationService');
        rethrow;
      }
      developer.log('Attempt $attempt failed, retrying... Error: $e', name: 'NotificationService');
      await Future.delayed(Duration(seconds: 1)); // Wait before retrying
    }
  }
}

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    developer.log('Cancelled notification with id: $id', name: 'NotificationService');
  }
}