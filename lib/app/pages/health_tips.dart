import 'dart:math';

class HealthTips {
  static final List<String> _tips = [
    "Drink at least 8 glasses of water daily to stay hydrated.",
    "Take a 10-minute walk after meals to aid digestion.",
    "Get 7-8 hours of sleep to improve your overall health.",
    "Eat a balanced diet rich in fruits and vegetables.",
    "Practice deep breathing exercises to reduce stress.",
    "Schedule regular check-ups with your doctor.",
    "Limit screen time before bed to improve sleep quality.",
    "Stay active with at least 30 minutes of exercise daily.",
    "Wash your hands frequently to prevent infections.",
    "Take breaks during work to avoid burnout.",
  ];

  static String getRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }
}