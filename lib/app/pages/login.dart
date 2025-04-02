import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/login_password_page.dart';
import 'package:flutter_project/app/pages/profile-page.dart';
import 'package:flutter_project/app/pages/services/auth_service.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStoredEmail();
  }

  Future<void> _loadStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('username');
    final storedFullName = prefs.getString('fullName');

    // One-time migration: If username matches full name, clear it
    if (storedEmail != null && storedFullName != null && storedEmail == storedFullName) {
      developer.log('Detected old username value matching full name, clearing username', name: 'LoginPage');
      await prefs.remove('username');
    }

    // Reload the username after migration
    final updatedStoredEmail = prefs.getString('username');
    if (updatedStoredEmail != null) {
      setState(() {
        _usernameController.text = updatedStoredEmail;
      });
      developer.log('Loaded stored username: $updatedStoredEmail', name: 'LoginPage');
    } else {
      developer.log('No stored username found', name: 'LoginPage');
    }

    if (storedFullName != null) {
      developer.log('Loaded stored full name: $storedFullName', name: 'LoginPage');
    }
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      developer.log('Attempting to check user with email: ${_usernameController.text}', name: 'LoginPage');
      final userResponse = await _authService.checkUser(_usernameController.text);
      developer.log('User response received: ${userResponse.toString()}', name: 'LoginPage');

      if (userResponse.success && userResponse.user != null) {
        developer.log('User found: ${userResponse.user!.toString()}', name: 'LoginPage');
        developer.log('Email from user response: ${userResponse.user!.email}', name: 'LoginPage');
        developer.log('First name: ${userResponse.user!.firstName}', name: 'LoginPage');
        developer.log('Last name: ${userResponse.user!.lastName}', name: 'LoginPage');

        final firstName = userResponse.user!.firstName;
        final lastName = userResponse.user!.lastName ?? '';
        final fullName = lastName.isEmpty ? firstName : '$firstName $lastName';
        final email = _usernameController.text;

        developer.log('Constructed full name: $fullName', name: 'LoginPage');
        developer.log('Email to save: $email', name: 'LoginPage');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', email);
        await prefs.setString('userId', userResponse.user!.id);
        await prefs.setString('fullName', fullName);

        developer.log('Email saved as username: $email', name: 'LoginPage');
        developer.log('Full name saved: $fullName', name: 'LoginPage');
        developer.log('UserId saved: ${userResponse.user!.id}', name: 'LoginPage');

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordPage(
              userId: userResponse.user!.id,
              username: email,
              fullName: fullName,
              profileImage: userResponse.user!.profileImage ?? '',
            ),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = userResponse.message;
        });
        developer.log('User check failed: ${userResponse.message}', name: 'LoginPage');
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e.toString().contains('Request timed out')) {
        errorMessage = 'Request timed out. Please check your network and try again.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('Failed host lookup')) {
        errorMessage = 'Unable to reach the server. The server might be down or the URL is incorrect.';
      } else {
        errorMessage = 'An unexpected error occurred: $e';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
      developer.log('Login error: $e', name: 'LoginPage');
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
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hi, Welcome back!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
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