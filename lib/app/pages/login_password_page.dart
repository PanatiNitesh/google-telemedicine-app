import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/profile-page.dart'; // Ensure this import is correct
import 'package:flutter_project/app/pages/services/auth_service.dart';
import 'dart:convert'; // For base64 decoding
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class PasswordPage extends StatefulWidget {
  final String userId;
  final String username; // This is the email
  final String fullName; // Add fullName parameter
  final String? profileImage; // Base64 string from backend

  const PasswordPage({
    super.key,
    required this.userId,
    required this.username,
    required this.fullName, // Add fullName to constructor
    this.profileImage,
  });

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  bool _obscureText = true; // Controls password visibility
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  // Instance of NotificationService
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Ensure NotificationService is initialized
    _notificationService.initialize();
  }

 Future<void> _verifyPassword() async {
  if (_passwordController.text.isEmpty) {
    setState(() {
      _errorMessage = 'Password is required';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final loginResponse = await _authService.verifyPassword(
      widget.userId,
      _passwordController.text,
    );

    if (loginResponse.success && loginResponse.user != null) {
      final prefs = await SharedPreferences.getInstance();
      // Save authentication details
      await prefs.setString('auth_token', loginResponse.token ?? '');
      await prefs.setString('user_id', loginResponse.user!.id);
      await prefs.setString('username', widget.username); // Store email as username
      await prefs.setString('fullName', widget.fullName); // Store fullName

      // Standardize profileImage format
      String? profileImageToSave = widget.profileImage;
      if (profileImageToSave != null && profileImageToSave.isNotEmpty) {
        // Ensure the profileImage has the correct prefix
        if (!profileImageToSave.startsWith('data:image')) {
          profileImageToSave = 'data:image/jpeg;base64,$profileImageToSave';
        }
        await prefs.setString('profileImage', profileImageToSave);
        developer.log('Saved profileImage to SharedPreferences: $profileImageToSave', name: 'PasswordPage');
      } else {
        await prefs.remove('profileImage'); // Clear if no profile image
        developer.log('No profileImage to save', name: 'PasswordPage');
      }
      // Set isLoggedIn to true
      await prefs.setBool('isLoggedIn', true);
      developer.log('Set isLoggedIn to true', name: 'PasswordPage');

      // Show the "Login Successful" notification
      await _notificationService.showImmediateNotification();
      developer.log('Login successful, notification shown', name: 'PasswordPage');

      if (!mounted) return;
// Use named route to navigate to HomePage, clearing all previous routes
Navigator.pushNamedAndRemoveUntil(
  context,
  '/home',
  (route) => false,
  arguments: {
    'username': widget.username,
    'fullName': widget.fullName,
    'profileImage': profileImageToSave, // Pass the standardized profileImage
  },
);

    } else {
      if (!mounted) return;
      setState(() {
        _errorMessage = loginResponse.message;
      });
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = 'Connection error. Please check your network and try again.';
    });
    developer.log('Password verification error: $e', name: 'PasswordPage');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildProfileImage() {
    if (widget.profileImage != null && widget.profileImage!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(widget.profileImage!);
        developer.log('Profile image decoded successfully, size: ${imageBytes.length} bytes', name: 'PasswordPage');
        return CircleAvatar(
          radius: 40,
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        developer.log('Error decoding profile image: $e', name: 'PasswordPage');
        return CircleAvatar(
          radius: 40,
          backgroundColor: Color.fromRGBO(158, 158, 158, 0.3), // Updated to Color.fromRGBO
          child: const Icon(Icons.person, size: 50, color: Colors.black),
        );
      }
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: Color.fromRGBO(158, 158, 158, 0.3), // Updated to Color.fromRGBO
      child: const Icon(Icons.person, size: 50, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.blue, // Updated to Colors.blue
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileImage(),
                const SizedBox(height: 20),
                Text(
                  "Hello ${widget.fullName}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Type your password",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Verify",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Not You?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}