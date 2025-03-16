import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: const ProfilePage(),
    initialRoute: '/',
    routes: {
      '/': (context) => const PlaceholderPage(title: 'Login'),
    },
  ));
}

// Use Azure URL for web, localhost for mobile (adjust as needed)
const String BASE_URL = kIsWeb
    ? 'https://backend-solution-challenge-dqfbfad9dmd2cua0.canadacentral-01.azurewebsites.net/api'
    : 'http://localhost:5000/api';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isSaving = false;
  String? token;

  // Form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  String? gender;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? profileImagePath;

  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    _loadTokenAndProfile();
  }

  Future<void> _loadTokenAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    if (token != null) {
      await _loadProfileData();
    } else {
      await _promptLogin();
    }
  }

  Future<void> _promptLogin() async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username (Email or First Name)'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final username = usernameController.text;
              final password = passwordController.text;
              if (username.isNotEmpty && password.isNotEmpty) {
                await _login(username, password);
                Navigator.pop(context);
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _login(String username, String password) async {
    try {
      final loginResponse = await http.post(
        Uri.parse('$BASE_URL/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (loginResponse.statusCode == 200) {
        final loginData = jsonDecode(loginResponse.body);
        final userId = loginData['user']['id'];

        final verifyResponse = await http.post(
          Uri.parse('$BASE_URL/verify-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'password': password}),
        );

        if (verifyResponse.statusCode == 200) {
          final verifyData = jsonDecode(verifyResponse.body);
          final prefs = await SharedPreferences.getInstance();
          setState(() {
            token = verifyData['token'];
          });
          await prefs.setString('token', token!);
          await _loadProfileData();
        } else {
          throw Exception('Login failed: ${verifyResponse.body}');
        }
      } else {
        throw Exception('User not found: ${loginResponse.body}');
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['profile'];
        setState(() {
          firstNameController.text = data['firstName'];
          lastNameController.text = data['lastName'];
          emailController.text = data['email'];
          phoneController.text = data['phoneNumber'] ?? '';
          dobController.text = data['dateOfBirth'];
          addressController.text = data['address'];
          idController.text = data['governmentId'];
          gender = genderOptions.contains(data['gender']) ? data['gender'] : null;
          profileImagePath = data['profileImage'] != null ? 'data:image/png;base64,${data['profileImage']}' : null;
        });
      } else {
        print('Failed to load profile: ${response.body}');
        await _loadLocalProfileData();
      }
    } catch (e) {
      print('Error loading profile: $e');
      await _loadLocalProfileData();
    }
  }

  Future<void> _loadLocalProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstNameController.text = prefs.getString('firstName') ?? 'John';
      lastNameController.text = prefs.getString('lastName') ?? 'Doe';
      emailController.text = prefs.getString('email') ?? 'example@gmail.com';
      phoneController.text = prefs.getString('phone') ?? '';
      dobController.text = prefs.getString('dob') ?? '1990-01-01';
      addressController.text = prefs.getString('address') ?? '7th street - medicine road, doctor 82';
      idController.text = prefs.getString('id') ?? '9999-8888-7777-6666';
      gender = genderOptions.contains(prefs.getString('gender')) ? prefs.getString('gender') : null;
      profileImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileData = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
      'phoneNumber': phoneController.text.isEmpty ? '' : phoneController.text,
      'dateOfBirth': dobController.text,
      'address': addressController.text,
      'governmentId': idController.text,
      'gender': gender ?? 'Male',
    };

    try {
      if (kIsWeb && profileImagePath != null && profileImagePath!.startsWith('data:image')) {
        final base64Image = profileImagePath!.split(',')[1];
        profileData['profileImage'] = base64Image;
      } else if (!kIsWeb && profileImagePath != null && !profileImagePath!.startsWith('data:image')) {
        var request = http.MultipartRequest('PUT', Uri.parse('$BASE_URL/profile'));
        request.headers['Authorization'] = 'Bearer $token';
        request.fields.addAll(profileData);
        final file = await http.MultipartFile.fromPath('profileImage', profileImagePath!);
        request.files.add(file);
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode != 200) {
          throw Exception('Failed to save profile: $responseBody');
        }
        final data = jsonDecode(responseBody)['profile'];
        await _savePrefs(prefs, data);
        return;
      }

      final response = await http.put(
        Uri.parse('$BASE_URL/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['profile'];
        await _savePrefs(prefs, data);
      } else {
        throw Exception('Failed to save profile: ${response.body}');
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  Future<void> _savePrefs(SharedPreferences prefs, Map<String, dynamic> data) async {
    await prefs.setString('firstName', data['firstName']);
    await prefs.setString('lastName', data['lastName']);
    await prefs.setString('email', data['email']);
    await prefs.setString('phone', data['phoneNumber'] ?? '');
    await prefs.setString('dob', data['dateOfBirth']);
    await prefs.setString('address', data['address']);
    await prefs.setString('id', data['governmentId']);
    await prefs.setString('gender', data['gender']);
    if (data['profileImage'] != null) {
      await prefs.setString('profileImagePath', 'data:image/png;base64,${data['profileImage']}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    idController.dispose();
    super.dispose();
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      token = null;
    });
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void toggleEditing() async {
    if (isEditing) {
      if (_validateForm()) {
        setState(() {
          isSaving = true;
        });
        await _saveProfileData();
        setState(() {
          isEditing = false;
          isSaving = false;
        });
      }
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First Name is required')),
      );
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Last Name is required')),
      );
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return false;
    }
    final phoneText = phoneController.text.trim();
    if (phoneText.isNotEmpty && !RegExp(r'^\+\d{1,3}\s\d{5,15}$').hasMatch(phoneText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number (e.g., +91 12345 6789)')),
      );
      return false;
    }
    if (dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date of Birth is required')),
      );
      return false;
    }
    final dob = DateTime.tryParse(dobController.text);
    if (dob == null || DateTime.now().difference(dob).inDays < 18 * 365) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be at least 18 years old')),
      );
      return false;
    }
    return true;
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!isEditing) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    if (!isEditing) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            profileImagePath = 'data:image/png;base64,${base64Encode(bytes)}';
          });
        } else {
          setState(() {
            profileImagePath = image.path;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              size: screenWidth * 0.05,
            ),
          ),
        ),
        title: Text(
          'Profile Summary',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.04),
            child: ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0062FF),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: screenWidth * 0.55,
                          height: screenWidth * 0.55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: screenWidth * 0.02,
                                spreadRadius: screenWidth * 0.01,
                              ),
                            ],
                          ),
                        ),
                        ClipOval(
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            color: Colors.transparent,
                            child: profileImagePath != null
                                ? Image.network(
                                    profileImagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      size: screenWidth * 0.15,
                                      color: Colors.black,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange[300],
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: screenWidth * 0.15,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: screenWidth * 0.08,
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: screenWidth * 0.05,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: screenWidth * 0.05,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'First Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleEditing,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEditing ? Icons.save : Icons.edit_outlined,
                                size: screenWidth * 0.045,
                                color: Colors.black,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                isEditing ? 'Save' : 'Edit',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  buildTextField(firstNameController, 'First Name'),
                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Last Name'),
                  buildTextField(lastNameController, 'Last Name'),
                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Gender'),
                  buildGenderDropdown(),
                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Email'),
                  buildTextField(emailController, 'example@gmail.com'),
                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Phone Number (Optional)'),
                  buildTextField(phoneController, '+91 12345 6789'),
                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Date of Birth'),
                  buildDateField(context),
                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Full Address'),
                  buildTextField(addressController, '7th street - medicine road, doctor 82'),
                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Government/Medical ID'),
                  buildTextField(idController, '9999-8888-7777-6666'),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
            if (isSaving)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.045,
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return Container(
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: Colors.black.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return Container(
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: Colors.black.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: gender,
        onChanged: isEditing
            ? (String? newValue) {
                setState(() {
                  gender = newValue;
                });
              }
            : null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          border: InputBorder.none,
        ),
        items: genderOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        hint: const Text('Select Gender'),
      ),
    );
  }

  Widget buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: screenHeight * 0.06,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(
            color: Colors.black.withOpacity(0.7),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dobController.text.isEmpty ? 'yyyy-mm-dd' : dobController.text,
                style: TextStyle(
                  color: dobController.text.isEmpty ? Colors.grey : Colors.black,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              Icon(
                Icons.calendar_today,
                size: screenWidth * 0.05,
                color: isEditing ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(child: Text('This is the $title page')),
    );
  }
}