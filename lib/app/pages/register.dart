import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Design with Back Button
            Stack(
              children: [
                ClipPath(
                  clipper: CustomClipPath(),
                  child: Container(
                    height: 200,
                    color: Colors.blue,
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 5,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/back.png', // Using provided back button image
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to main.dart
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Register Title
            const Text(
              "Register",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField("Full Name"),
                  const SizedBox(height: 10),
                  _buildTextField("Email"),
                  const SizedBox(height: 10),
                  _buildTextField("Password", obscureText: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Done Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Done"),
            ),

            const SizedBox(height: 20),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider(thickness: 1, indent: 40, endIndent: 10)),
                const Text("Or Sign-In with"),
                const Expanded(child: Divider(thickness: 1, indent: 10, endIndent: 40)),
              ],
            ),

            const SizedBox(height: 10),

            // Social Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon("assets/google.png"),
                _buildSocialIcon("assets/microsoft.png"),
                _buildSocialIcon("assets/apple.png"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TextField Widget
  Widget _buildTextField(String hintText, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Social Icon Widget
  Widget _buildSocialIcon(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Image.asset(
        assetPath,
        height: 40,
        width: 40,
      ),
    );
  }
}

// Custom ClipPath for top design
class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}