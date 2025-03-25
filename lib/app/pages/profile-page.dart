
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer' as developer;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/app_logo');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'profile_channel',
      'Profile Updates',
      description: 'Notifications for profile updates',
      importance: Importance.max,
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'profile_channel',
      'Profile Updates',
      channelDescription: 'Notifications for profile updates',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    developer.log('All notifications canceled', name: 'NotificationService');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(MaterialApp(
    home: const ProfilePage(),
    initialRoute: '/',
    routes: {
      '/': (context) => const PlaceholderPage(title: 'Login'),
    },
  ));
}

String baseUrl = 'https://backend-solution-challenge-dqfbfad9dmd2cua0.canadacentral-01.azurewebsites.net/api';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isSaving = false;
  bool isLoading = true;
  String? token;
  String? username;

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
    _loadUserData();
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
      isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loaded profile from local storage')),
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('auth_token');
      username = prefs.getString('username');
    });

    final storedFullName = prefs.getString('fullName');
    if (username != null && storedFullName != null && (username == storedFullName || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(username!))) {
      developer.log('Detected invalid username: $username, clearing it', name: 'ProfilePage');
      await prefs.remove('username');
      setState(() {
        username = null;
      });
    }

    developer.log('SharedPreferences - token: $token, username: $username', name: 'ProfilePage');

    if (token != null && username != null) {
      await _loadProfileData();
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['profile'];
        setState(() {
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phoneNumber'] ?? '';
          dobController.text = data['dateOfBirth'] ?? '';
          addressController.text = data['address'] ?? '';
          idController.text = data['governmentId'] ?? '';
          gender = genderOptions.contains(data['gender']) ? data['gender'] : null;
          
          if (data['profileImage'] != null) {
            profileImagePath = 'data:image/jpeg;base64,${data['profileImage']}';
          } else {
            profileImagePath = null;
          }
        });
      } else {
        developer.log('Failed to load profile: ${response.body}', name: 'ProfilePage');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data from server')),
        );
        await _loadLocalProfileData();
      }
    } catch (e) {
      developer.log('Error loading profile: $e', name: 'ProfilePage');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
      await _loadLocalProfileData();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildProfileImage() {
    return Container(
      width: screenWidth * 0.3,
      height: screenWidth * 0.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipOval(
        child: profileImagePath != null
            ? Image.network(
                profileImagePath!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: screenWidth * 0.15,
                    color: Colors.white,
                  );
                },
              )
            : Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: screenWidth * 0.15,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    if (!isEditing) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            profileImagePath = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          });
        } else {
          setState(() {
            profileImagePath = image.path;
          });
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      developer.log('Error picking image: $e', name: 'ProfilePage');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileData = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
      'phoneNumber': phoneController.text.isEmpty ? null : phoneController.text,
      'dateOfBirth': dobController.text,
      'address': addressController.text,
      'governmentId': idController.text,
      'gender': gender ?? 'Male',
    };

    try {
      if (profileImagePath != null && profileImagePath!.startsWith('data:image')) {
        final base64Image = profileImagePath!.split(',')[1];
        profileData['profileImage'] = base64Image;
      } else if (!kIsWeb && profileImagePath != null) {
        var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/profile'));
        request.headers['Authorization'] = 'Bearer $token';
        
        profileData.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        
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
        Uri.parse('$baseUrl/profile'),
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
      developer.log('Error saving profile: $e', name: 'ProfilePage');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
      );
    }
  }

  Future<void> _savePrefs(SharedPreferences prefs, Map<String, dynamic> data) async {
    final fullName = '${data['firstName']} ${data['lastName']}'.trim();
    await prefs.setString('fullName', fullName);
    await prefs.setString('username', data['email']);
    await prefs.setString('phone', data['phoneNumber'] ?? '');
    await prefs.setString('dob', data['dateOfBirth']);
    await prefs.setString('address', data['address']);
    await prefs.setString('id', data['governmentId']);
    await prefs.setString('gender', data['gender']);
    if (data['profileImage'] != null) {
      await prefs.setString('profileImage', 'data:image/png;base64,${data['profileImage']}');
    }
    if (!mounted) return;
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
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await NotificationService().cancelAllNotifications();
      await prefs.clear();
      setState(() {
        token = null;
        username = null;
      });
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void toggleEditing() async {
    if (isEditing) {
      if (_validateForm()) {
        setState(() {
          isSaving = true;
        });
        await _saveProfileData();
        if (!mounted) return;
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
            child: Image.asset(
              'assets/back.png',
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                developer.log('Error loading back icon: $error', name: 'ProfilePage');
                return Icon(
                  Icons.arrow_back,
                  size: screenWidth * 0.05,
                  color: Colors.black,
                );
              },
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
            isLoading
                ? _buildSkeletonLoading()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: Container(
                                  width: screenWidth * 0.3,
                                  height: screenWidth * 0.3,
                                  color: Colors.transparent,
                                  child: profileImagePath != null && profileImagePath!.startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(profileImagePath!.split(',')[1]),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            developer.log('Error loading profile image: $error', name: 'ProfilePage');
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.orange[300],
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: screenWidth * 0.15,
                                                color: Colors.black,
                                              ),
                                            );
                                          },
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
                                  border: Border.all(color: Colors.grey.withAlpha((0.3 * 255).round())),
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
                color: Colors.black.withAlpha((0.5 * 255).round()),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: screenHeight * 0.03,
                  color: Colors.white,
                ),
                Container(
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.03),
            _buildSkeletonLabel(),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.03),
            _buildSkeletonLabel(),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.03),
            _buildSkeletonLabel(),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.03),
            _buildSkeletonLabel(),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.03),
            _buildSkeletonLabel(),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.03),
            _buildSkeletonLabel(),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.03),
            _buildSkeletonLabel(),
            _buildSkeletonField(),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLabel() {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Container(
        width: screenWidth * 0.3,
        height: screenHeight * 0.03,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSkeletonField() {
    return Container(
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
          color: Colors.black.withAlpha((0.7 * 255).round()),
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
          color: Colors.black.withAlpha((0.7 * 255).round()),
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
            color: Colors.black.withAlpha((0.7 * 255).round()),
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