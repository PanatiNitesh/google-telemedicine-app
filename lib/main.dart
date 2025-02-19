import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/pages/login.dart';
import 'app/pages/register.dart';

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
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Slanted Blue Background
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
          // Login Button
          Positioned(
            top: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
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
            bottom: 150,
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
            child: SizedBox(
              height: 250, // Adjust as needed
              width: 200,
              child: Image.asset(
                'assets/doctor.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
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
    );
  }
}

// Custom ClipPath for slanted background
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