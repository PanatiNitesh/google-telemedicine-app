import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart' as home_page; // Changed prefix to home_page
import 'package:flutter_project/app/pages/ProfilePage.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'app/pages/login.dart'; // Import LoginPage
import 'app/pages/register.dart'; // Import RegisterPage
import 'app/pages/chat_bot.dart' as chat_bot; // Changed prefix to chat_bot
import 'app/pages/search_page.dart'; // Ensure this file exists or correct the path

void main() {
  runApp(const TelemedicineApp());
}

class TelemedicineApp extends StatelessWidget {
  const TelemedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const MainPage(), // Start with MainPage
      routes: {
        '/login': (context) => const LoginPage(), // Route for LoginPage
        '/register': (context) =>  RegisterPage(), // Route for RegisterPage
        '/home': (context) {
          // Extract the username from the arguments
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final username = args != null ? args['username'] as String : 'User'; // Fallback to 'User'
          return home_page.HomePage(username: username);
        }, // Route for HomePage
        '/profile': (context) => ProfilePage(), // Route for ProfilePage
        '/ai_diagnose': (context) => const chat_bot.ChatScreen(), // Route for ChatScreen
        '/search': (context) => const SearchPage(), // Route for SearchPage
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
            // Slanted Blue Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: CustomClip(), // Custom clipper for slanted design
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.blue,
                ),
              ),
            ),

            // Login Button
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Navigate to LoginPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("Login"),
              ),
            ),

            // "Smart Healthcare for Everyone" Text
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

            // Doctor Image
            Positioned(
              bottom: 20,
              right: 10,
              child: Image.asset(
                'assets/doctor.png', // Ensure this image exists in your assets folder
                height: 250,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),

            // Get Started Button
            Positioned(
              left: 20,
              bottom: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register'); // Navigate to RegisterPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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

// Custom ClipPath for slanted background
class CustomClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80); // Start from top-left
    path.lineTo(size.width, size.height * 0.3); // Draw diagonal line
    path.lineTo(size.width, 0); // Close the path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false; // No need to reclip
}