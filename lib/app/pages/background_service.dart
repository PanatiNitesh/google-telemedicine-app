import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  final AndroidConfiguration androidConfig = AndroidConfiguration(
    onStart: onStart,
    isForegroundMode: true,
    autoStart: true,
  );

  final IosConfiguration iosConfig = IosConfiguration(
    onForeground: onStart,
    onBackground: onIosBackground,
  );

  await service.configure(
    androidConfiguration: androidConfig,
    iosConfiguration: iosConfig,
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  showNotification(notificationsPlugin, "Service Started", "Background service is running");

  Timer.periodic(const Duration(minutes: 2), (timer) async {
    if (service is AndroidServiceInstance && !(await service.isForegroundService())) {
      timer.cancel();
      return;
    }

    showNotification(notificationsPlugin, "Update", "Service is still running...");
  });
}

void showNotification(
    FlutterLocalNotificationsPlugin notificationsPlugin, String title, String body) {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'background_service',
    'Background Service',
    importance: Importance.high,
    priority: Priority.high,
    ongoing: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
  notificationsPlugin.show(0, title, body, platformDetails);
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}