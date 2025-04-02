import 'dart:math';

class HealthTips {
  static final List<String> _tips = [
    "💧 Drink at least 8 glasses of water daily to stay hydrated.",
    "🚶 Take a 10-minute walk after meals to aid digestion.",
    "😴 Get 7-8 hours of sleep to improve your overall health.",
    "🥗 Eat a balanced diet rich in fruits and vegetables.",
    "🧘 Practice deep breathing exercises to reduce stress.",
    "👩‍⚕ Schedule regular check-ups with your doctor.",
    "📵 Limit screen time before bed to improve sleep quality.",
    "🏃 Stay active with at least 30 minutes of exercise daily.",
    "🧼 Wash your hands frequently to prevent infections.",
    "⏱ Take breaks during work to avoid burnout.",
    "🧠 Challenge your brain with puzzles to keep it sharp.",
    "🥤 Reduce sugary drinks to maintain a healthy weight.",
    "☀ Get 15 minutes of sunlight daily for vitamin D.",
    "🧹 Keep your living space clean to reduce allergens.",
    "💪 Include strength training in your exercise routine.",
    "🥦 Aim for at least 5 servings of vegetables daily.",
    "🌱 Try incorporating plant-based meals into your diet.",
    "🚭 Avoid smoking and second-hand smoke exposure.",
    "💊 Take medications as prescribed by your doctor.",
    "💬 Connect with friends and family to boost mental health.",
  ];

  static String getRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }
  
  static String getNotification() {
    return "🔔 Health Tip: ${getRandomTip()}";
  }
}