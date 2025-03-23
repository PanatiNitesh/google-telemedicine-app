class HealthTips {
  static final List<String> tips = [
    "Drink at least 8 glasses of water today to stay hydrated!",
    "Take a 10-minute walk to boost your mood and energy.",
    "Eat a piece of fruit for a healthy snack instead of processed foods.",
    "Practice deep breathing for 5 minutes to reduce stress.",
    "Get 7-8 hours of sleep tonight for better health.",
    "Stretch for 5 minutes to improve flexibility and reduce tension.",
    "Avoid sugary drinks—opt for herbal tea or water instead.",
    "Take a break from screens every hour to rest your eyes.",
    "Eat more vegetables with your meals for added nutrients.",
    "Stay active—try a quick home workout or yoga session today!",
  ];

  static String getRandomTip() {
    return tips[DateTime.now().millisecondsSinceEpoch % tips.length];
  }
}