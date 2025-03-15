import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/app/pages/DoctorListPage.dart';
import 'package:flutter_project/app/pages/HomePage.dart' as home_page;
import 'package:flutter_project/app/pages/medicines_list_page.dart';
import 'package:flutter_project/app/pages/profile-page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_project/app/pages/login.dart';
import 'package:flutter_project/app/pages/register.dart';
import 'package:flutter_project/app/pages/chat_bot.dart' as chat_bot;
import 'package:flutter_project/app/pages/search_page.dart';
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:flutter_project/app/pages/medicine_page.dart';
import 'package:flutter_project/app/pages/labtests.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeDotEnv() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await dotenv.load(fileName: "assets/.env");
      print("Loaded .env successfully");
    } catch (e) {
      print("Error loading .env: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeDotEnv(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TelemedicineApp();
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ); // Show loading indicator while .env loads
        }
      },
    );
  }
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
        '/register': (context) => const RegisterPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] as String? ?? 'User';
          return home_page.HomePage(username: username);
        },
        '/profile': (context) => const ProfilePage(),
        '/ai_diagnose': (context) => const chat_bot.ChatScreen(),
        '/search': (context) => const SearchPage(),
        '/doctors_list': (context) => const DoctorsListPage(),
        '/test_results': (context) => const TestResults(),
        '/medicines': (context) => const MedicinesListPage(), // Now shows the dropdown list
        '/lab_tests': (context) => const LabTestsApp(),
        '/medicines-list': (context) {
          final String? medicineName = ModalRoute.of(context)?.settings.arguments as String?;
          return MedicinePage(medicineName: medicineName);
        },
      },
      onGenerateRoute: (settings) {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Blue background shape
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: CustomClip(),
                child: Container(
                  height: screenHeight * 0.4,
                  color: Colors.blue,
                ),
              ),
            ),
            // Secondary shape with color #DCE1FE
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: SecondaryClip(),
                child: Container(
                  height: screenHeight * 0.4,
                  color: const Color(0xFFDCE1FE), // Color code #DCE1FE
                ),
              ),
            ),
            // About Us button
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.05,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('About Us feature coming soon!'),
                    ),
                  );
                },
                child: Text(
                  "About Us",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.04,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Login button
            Positioned(
              top: screenHeight * 0.03,
              right: screenWidth * 0.05,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.015,
                  ),
                ),
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Main text and tagline
            Positioned(
              left: screenWidth * 0.05,
              bottom: screenHeight * 0.28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Smart Healthcare\nfor Everyone",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Access quality care\nanytime, anywhere",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Doctor image
            Positioned(
              bottom: screenHeight * 0.01, // Adjusted to position the image lower
              right: screenWidth * 0.03,
              child: Image.asset(
                'assets/doctor.png',
                height: screenHeight * 0.35,
                width: screenWidth * 0.5,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  size: 100,
                ),
              ),
            ),
            // Get Started button
            Positioned(
              left: screenWidth * 0.05,
              bottom: screenHeight * 0.06,
              child: AnimatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ),
            // Dots indicator for feature carousel
            Positioned(
              left: screenWidth * 0.05,
              bottom: screenHeight * 0.03,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    width: screenWidth * 0.02,
                    height: screenWidth * 0.02,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0 ? Colors.blue : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for the blue background
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

// Custom Clipper for the secondary shape (#DCE1FE)
class SecondaryClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.4, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.3,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Animated Button Widget for Get Started
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double screenWidth;
  final double screenHeight;

  const AnimatedButton({
    required this.onPressed,
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.screenWidth * 0.03),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.screenWidth * 0.08,
                vertical: widget.screenHeight * 0.02,
              ),
            ),
            child: Text(
              "Get Started",
              style: GoogleFonts.poppins(
                fontSize: widget.screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}