import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;

  UserResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}

class User {
  final String id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? profileImage;

  User({
    required this.id,
    required this.firstName,
    this.lastName,
    this.email,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }
}

class AuthService {
  static final String? _baseUrl = dotenv.env['BASE_URL'];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserResponse> checkUser(String username) async {
    final url = Uri.parse('$_baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username});

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out after 30 seconds.'),
      );
      return UserResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Error in checkUser: $e');
    }
  }

  Future<UserResponse> verifyPassword(String userId, String password) async {
    final url = Uri.parse('$_baseUrl/verify-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'userId': userId, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out after 30 seconds.'),
      );
      return UserResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Error in verifyPassword: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _storage.write(
        key: 'google_access_token',
        value: googleAuth.accessToken,
      );
      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in error: $e');
    }
  }
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();

      if (kIsWeb) {
        appleProvider.addScope('email');
        appleProvider.addScope('name');
      }

      final UserCredential userCredential = await _firebaseAuth.signInWithProvider(appleProvider);

      if (userCredential.user != null) {
        await _storage.write(
          key: 'apple_user_id',
          value: userCredential.user?.uid,
        );
      }

      return userCredential;
    } catch (e) {
      print('Apple sign-in error: $e');
      return null;
    }
  }
}