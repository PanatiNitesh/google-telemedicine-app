import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_project/app/pages/notificationservice.dart'; // Updated import path
import 'dart:developer' as developer;

// Initialize the background service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Android configuration
  final AndroidConfiguration androidConfig = AndroidConfiguration(
    onStart: onStart,
    isForegroundMode: true,
    autoStart: true,
  );

  // iOS configuration
  final IosConfiguration iosConfig = IosConfiguration(
    onForeground: onStart,
    onBackground: onIosBackground,
  );

  // Configure the service
  await service.configure(
    androidConfiguration: androidConfig,
    iosConfiguration: iosConfig,
  );

  // Start the service
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Ensure the service runs as a foreground service on Android
  if (service is AndroidServiceInstance) {
    // Set the foreground notification info
    service.setForegroundNotificationInfo(
      title: 'Telemedicine App',
      content: 'Running in the background to send health tips',
    );
    service.setAsForegroundService();
  }

  // Initialize the NotificationService
  final notificationService = NotificationService();
  await notificationService.init();

  // Set up periodic health tip notifications every 2 minutes
  Timer.periodic(const Duration(minutes: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (!(await service.isForegroundService())) {
        developer.log("Service is no longer in foreground, stopping timer.", name: 'BackgroundService');
        timer.cancel();
        return;
      }
    }

    developer.log("Sending health tip notification at ${DateTime.now()}", name: 'BackgroundService');
    await notificationService.sendHealthTipNotification();
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  developer.log("iOS background task running", name: 'BackgroundService');
  return true;
}