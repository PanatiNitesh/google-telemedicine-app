import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class UserResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token; // Add token field for JWT

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
      token: json['token'], // Extract token from response
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
  static const String _baseUrl = 'https://backend-solution-challenge-dqfbfad9dmd2cua0.canadacentral-01.azurewebsites.net/api';

  Future<UserResponse> checkUser(String username) async {
    final url = Uri.parse('$_baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username});

    developer.log('Sending login request to: $url', name: 'AuthService');
    developer.log('Request body: $body', name: 'AuthService');

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timed out after 30 seconds.');
      });

      developer.log('Response status: ${response.statusCode}', name: 'AuthService');
      developer.log('Response body: ${response.body}', name: 'AuthService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to check user',
        );
      }
    } catch (e) {
      developer.log('Error in checkUser: $e', name: 'AuthService');
      rethrow;
    }
  }

  Future<UserResponse> verifyPassword(String userId, String password) async {
    final url = Uri.parse('$_baseUrl/verify-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'userId': userId, 'password': password});

    developer.log('Sending verify password request to: $url', name: 'AuthService');
    developer.log('Request body: $body', name: 'AuthService');

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timed out after 30 seconds.');
      });

      developer.log('Response status: ${response.statusCode}', name: 'AuthService');
      developer.log('Response body: ${response.body}', name: 'AuthService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return UserResponse(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to verify password',
        );
      }
    } catch (e) {
      developer.log('Error in verifyPassword: $e', name: 'AuthService');
      rethrow;
    }
  }
}