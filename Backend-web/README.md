# 🏥 Smart Healthcare App - Hackathon Project

## 📌 Overview
The Smart Healthcare App is a Flutter-based medical assistant designed for a hackathon. It seamlessly integrates AI-driven chatbot assistance, appointment scheduling, medication reminders, and lab test result management, ensuring a user-friendly and efficient healthcare experience.

## ✨ Features
### 🧠 AI-Powered Health Assistant
- Uses **Vertex AI API** for chatbot-based healthcare suggestions.
- **Speech-to-Text** integration for hands-free interaction.
- Users receive **basic health guidance** but are always advised to consult a doctor.

### 📅 Appointment Booking & History
- Easily **book consultations** with doctors.
- **Track past and upcoming appointments** with timeline and list views.
- Smart sorting and filtering by **category and date**.

### 💊 Medicine Management
- **Set medication reminders** and track dosages.
- **Calendar integration** to view and manage medication schedules.
- Store and retrieve medicine history.

### 🧪 Lab Test Results
- View **detailed reports** of medical tests.
- Secure **download and storage** of reports.
- Easy **sharing** of test results with healthcare providers.

### 🔔 Notifications & Alerts
- Real-time **appointment reminders** and **medicine notifications**.
- Flutter’s **local notifications** for enhanced user engagement.

### 🏠 Intuitive User Experience
- **Modern UI/UX design** for seamless navigation.
- **Dark & Light Mode** support.
- **Smooth animations & transitions**.

## 🚀 Installation & Setup
### ✅ Prerequisites
- **Flutter SDK** installed ([Guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK** installed ([Get Dart](https://dart.dev/get-dart))
- **Android Studio / VS Code** with Flutter plugin
- **Cohere API Key** (for AI chatbot integration)

### ⚡ Setup Instructions
1️⃣ **Clone the repository:**
```sh
git clone https://github.com/your-repo-name.git
cd your-repo-name
```

2️⃣ **Install dependencies:**
```sh
flutter pub get
```

3️⃣ **Configure API Keys:**
Create a `.env` file in the root directory and add:
```env
COHERE_API_KEY=your_api_key_here
```

4️⃣ **Run the application:**
```sh
flutter run
```

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Authentication & Database Storage)
- **APIs:** Cohere AI (Chatbot), Google APIs (Speech-to-Text)
- **State Management:** Provider
- **Local Storage:** Shared Preferences

## 📂 Project Structure
```
/lib
  ├── pages
  │   ├── appointment_history.dart
  │   ├── book_appointment.dart
  │   ├── medicine_page.dart
  │   ├── test_results.dart
  │   ├── chat_bot.dart
  ├── services
  │   ├── notification_service.dart
  ├── main.dart
  ├── widgets
  ├── assets
```

## 📖 Usage Guide
### 🤖 Chat with AI Assistant
- Open the chatbot screen and ask health-related questions.
- Voice-based interaction available.
- AI provides **basic guidance**, but users are advised to **consult a doctor**.

### 📌 Book Appointments
- Select a **doctor**, choose a **date and time**, and confirm your booking.
- View and manage **past & upcoming appointments**.

### 💊 Manage Medications
- Track medicines with **daily reminders**.
- **Set dosage schedules** and receive notifications.

### 📊 View Lab Reports
- Securely **view & download** test reports.
- Reports are categorized for **easy access**.

## 👥 Contributors
👨‍💻 **Ravindra S.** *(Lead Developer & AI Integration)*
👨‍💻 **P Nitesh.** *(Full stack Developer)*
👨‍💻 **Pooja CG.** *(Frontend Developer)*

## 📜 License
This project is open-source under the **MIT License**. Contributions are welcome!

---
*Developed for [Google Solution Code] 🏆.* 🚀

