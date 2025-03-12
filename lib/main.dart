import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/DoctorListPage.dart';
import 'package:flutter_project/app/pages/HomePage.dart' as home_page;
import 'package:flutter_project/app/pages/ProfilePage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_project/app/pages/login.dart'; // Use package import
import 'package:flutter_project/app/pages/register.dart'; // Use package import
import 'package:flutter_project/app/pages/chat_bot.dart' as chat_bot;
import 'package:flutter_project/app/pages/search_page.dart'; // Add missing pages
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:flutter_project/app/pages/medicine_page.dart';
import 'package:flutter_project/app/pages/labtests.dart';

void main() {
  runApp(const TelemedicineApp());
}

class TelemedicineApp extends StatelessWidget {
  const TelemedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] as String? ?? 'User'; // Safer null handling
          return home_page.HomePage(username: username);
        },
        '/profile': (context) => ProfilePage(),
        '/ai_diagnose': (context) => const chat_bot.ChatScreen(),
        '/search': (context) => const SearchPage(),
        '/doctors_list': (context) => const DoctorsListPage(),
        '/test_results': (context) => const TestResults(),
        '/medicines': (context) => const MedicinePage(),
        '/lab_tests': (context) => const LabTestsApp(),
      },
      onGenerateRoute: (settings) {
        // Fallback for undefined routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: CustomClip(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.blue,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("Login"),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 160,
              child: Text(
                "Smart Healthcare\nfor Everyone",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 10,
              child: Image.asset(
                'assets/doctor.png',
                height: 250,
                width: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 100),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text("Get Started"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}