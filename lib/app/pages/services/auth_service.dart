import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

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
  Future<UserResponse> checkUser(String username) async {
    final url = Uri.parse('$_baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username});

    developer.log('Sending login request to: $url', name: 'AuthService');
    developer.log('Request body: $body', name: 'AuthService');

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out after 30 seconds.');
            },
          );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log('Response body: ${response.body}', name: 'AuthService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse(
          success: false,
          message:
              jsonResponse['message'] ??
              'Failed to check user (Status: ${response.statusCode})',
        );
      }
    } on TimeoutException catch (e) {
      developer.log('Error in checkUser: $e', name: 'AuthService');
      throw Exception('Request timed out: $e');
    } on http.ClientException catch (e) {
      developer.log('Error in checkUser: $e', name: 'AuthService');
      throw Exception('Network error: $e');
    } on Exception catch (e) {
      developer.log('Error in checkUser: $e', name: 'AuthService');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserResponse> verifyPassword(String userId, String password) async {
    final url = Uri.parse('$_baseUrl/verify-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'userId': userId, 'password': password});

    developer.log(
      'Sending verify password request to: $url',
      name: 'AuthService',
    );
    developer.log('Request body: $body', name: 'AuthService');

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out after 30 seconds.');
            },
          );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log('Response body: ${response.body}', name: 'AuthService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse(
          success: false,
          message:
              jsonResponse['message'] ??
              'Failed to verify password (Status: ${response.statusCode})',
        );
      }
    } on TimeoutException catch (e) {
      developer.log('Error in verifyPassword: $e', name: 'AuthService');
      throw Exception('Request timed out: $e');
    } on http.ClientException catch (e) {
      developer.log('Error in verifyPassword: $e', name: 'AuthService');
      throw Exception('Network error: $e');
    } on Exception catch (e) {
      developer.log('Error in verifyPassword: $e', name: 'AuthService');
      throw Exception('Unexpected error: $e');
    }
  }
}
