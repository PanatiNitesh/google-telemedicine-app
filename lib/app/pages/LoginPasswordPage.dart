import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/homepage.dart';
import 'package:flutter_project/app/pages/services/auth_service.dart';
import 'dart:convert'; // For base64 decoding
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class PasswordPage extends StatefulWidget {
  final String userId;
  final String username;
  final String? profileImage; // Base64 string from backend

  const PasswordPage({
    super.key,
    required this.userId,
    required this.username,
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
        await prefs.setString('username', loginResponse.user!.firstName);
        // Save profile image if it exists
        if (widget.profileImage != null && widget.profileImage!.isNotEmpty) {
          await prefs.setString('profileImage', widget.profileImage!);
          developer.log('Saved profileImage to SharedPreferences: ${widget.profileImage}', name: 'PasswordPage');
        } else {
          await prefs.remove('profileImage'); // Clear if no profile image
          developer.log('No profileImage to save', name: 'PasswordPage');
        }
        // Set isLoggedIn to true
        await prefs.setBool('isLoggedIn', true);
        developer.log('Set isLoggedIn to true', name: 'PasswordPage');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              username: loginResponse.user!.firstName,
              profileImage: widget.profileImage, // Pass profileImage to HomePage
            ),
          ),
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
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, size: 50, color: Colors.black),
        );
      }
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey[300],
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
              decoration: const BoxDecoration(
                color: Colors.blue,
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
                  "Hello ${widget.username}",
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