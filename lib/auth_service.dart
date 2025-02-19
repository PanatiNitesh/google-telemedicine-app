class AuthService {
  Future<bool> login(String email) async {
    // Simulating a backend response (Replace with Firebase Auth)
    await Future.delayed(const Duration(seconds: 2));

    if (email == "test@example.com") {
      return true; // Success
    }
    return false; // Failure
  }
}
