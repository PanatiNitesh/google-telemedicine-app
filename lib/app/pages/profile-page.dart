import 'dart:convert';
import 'dart:io' show Platform, File;
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
import 'package:flutter_project/app/pages/HomePage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    const InitializationSettings initializationSettings =
        InitializationSettings(
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
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    developer.log('All notifications canceled', name: 'NotificationService');
  }

  void init() {}

  showImmediateNotification() {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await dotenv.load();
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const ProfilePage(),
      initialRoute: '/',
      routes: {'/': (context) => const PlaceholderPage(title: 'Login')},
    ),
  );
}

String? baseUrl = dotenv.env['BASE_URL'];

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
  String? userCode;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();

  String? gender;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? profileImagePath;
  bool privacyMode = false;

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
      firstNameController.text = prefs.getString('firstName') ?? 'Nitesh';
      lastNameController.text = prefs.getString('lastName') ?? 'P';
      emailController.text =
          prefs.getString('username') ?? 'niteshreddy242005@gmail.com';
      phoneController.text = prefs.getString('phone') ?? '';
      dobController.text = prefs.getString('dob') ?? '1990-01-01';
      addressController.text =
          prefs.getString('address') ?? '7th street - medicine road, doctor 82';
      idController.text = prefs.getString('id') ?? 'UPQ935';
      bloodGroupController.text =
          prefs.getString('bloodGroup') ?? ''; // Add this line
      gender =
          genderOptions.contains(prefs.getString('gender'))
              ? prefs.getString('gender')
              : null;
      profileImagePath = prefs.getString('profileImage');
      privacyMode = prefs.getBool('privacyMode') ?? false;
      isLoading = false;
    });

    developer.log('Loaded local profile data:', name: 'ProfilePage');
    developer.log(
      'firstName: ${firstNameController.text}',
      name: 'ProfilePage',
    );
    developer.log('lastName: ${lastNameController.text}', name: 'ProfilePage');
    developer.log('email: ${emailController.text}', name: 'ProfilePage');
    developer.log('id: ${idController.text}', name: 'ProfilePage');
    developer.log('privacyMode: $privacyMode', name: 'ProfilePage');

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
      userCode = prefs.getString('id') ?? 'UPQ935';
    });

    final storedFullName = prefs.getString('fullName');
    if (username != null &&
        storedFullName != null &&
        (username == storedFullName ||
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(username!))) {
      developer.log(
        'Detected invalid username: $username, clearing it',
        name: 'ProfilePage',
      );
      await prefs.remove('username');
      setState(() {
        username = null;
      });
    }

    developer.log(
      'SharedPreferences - token: $token, username: $username',
      name: 'ProfilePage',
    );

    if (token != null && username != null) {
      await _loadProfileData();
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        _loadLocalProfileData();
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
          firstNameController.text = data['firstName'] ?? 'Nitesh';
          lastNameController.text = data['lastName'] ?? 'P';
          emailController.text = data['email'] ?? 'niteshreddy242005@gmail.com';
          phoneController.text = data['phoneNumber'] ?? '';
          dobController.text = data['dateOfBirth'] ?? '1990-01-01';
          addressController.text =
              data['address'] ?? '7th street - medicine road, doctor 82';
          idController.text = data['governmentId'] ?? 'UPQ935';
          bloodGroupController.text = data['bloodGroup'] ?? ''; // Add this line
          gender =
              genderOptions.contains(data['gender']) ? data['gender'] : null;
          userCode = data['governmentId'] ?? 'UPQ935';

          if (data['profileImage'] != null) {
            profileImagePath = 'data:image/jpeg;base64,${data['profileImage']}';
          } else {
            profileImagePath = null;
          }
        });
      } else {
        developer.log(
          'Failed to load profile: ${response.body}',
          name: 'ProfilePage',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load profile data from server'),
          ),
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
    return GestureDetector(
      onTap: isEditing ? _pickProfileImage : null,
      child: Container(
        width: screenWidth * 0.25,
        height: screenWidth * 0.25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 6.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Stack(
          children: [
            SizedBox(
              width: 100, // Ensure this matches your desired circle size
              height: 100,
              child: ClipOval(
                child:
                    profileImagePath != null
                        ? profileImagePath!.startsWith('data:image')
                            ? Image.memory(
                              base64Decode(profileImagePath!.split(',')[1]),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              alignment:
                                  Alignment.center, // Ensure it’s centered
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultProfileIcon();
                              },
                            )
                            : (!kIsWeb
                                ? Image.file(
                                  File(profileImagePath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultProfileIcon();
                                  },
                                )
                                : Image.network(
                                  profileImagePath!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultProfileIcon();
                                  },
                                ))
                        : _buildDefaultProfileIcon(),
              ),
            ),
            if (isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: screenWidth * 0.05,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProfileIcon() {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.person, size: screenWidth * 0.15, color: Colors.white),
    );
  }

 Future<void> _pickProfileImage() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 50,  
    maxWidth: 800,     
    maxHeight: 800,
  );

  if (image == null) return;

  final bytes = await image.readAsBytes();
  if (bytes.length > 2 * 1024 * 1024) { // 2MB limit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image must be <2MB')),
    );
    return;
  }

  setState(() {
    profileImagePath = 'data:image/jpeg;base64,${base64Encode(bytes)}';
  });
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
      'bloodGroup': bloodGroupController.text,
    };

    try {
      if (profileImagePath != null &&
          profileImagePath!.startsWith('data:image')) {
        final base64Image = profileImagePath!.split(',')[1];
        profileData['profileImage'] = base64Image;
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
      // Save locally as fallback
      await prefs.setString('firstName', firstNameController.text);
      await prefs.setString('lastName', lastNameController.text);
      await prefs.setString('username', emailController.text);
      await prefs.setString('phone', phoneController.text);
      await prefs.setString('dob', dobController.text);
      await prefs.setString('address', addressController.text);
      await prefs.setString('id', idController.text);
      await prefs.setString('gender', gender ?? 'Male');
      await prefs.setString('bloodGroup', bloodGroupController.text);
      await prefs.setBool('privacyMode', privacyMode);
      if (profileImagePath != null) {
        await prefs.setString('profileImage', profileImagePath!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved locally')));
    }
  }

  Future<void> _savePrefs(
    SharedPreferences prefs,
    Map<String, dynamic> data,
  ) async {
    final fullName = '${data['firstName']} ${data['lastName']}'.trim();
    await prefs.setString('fullName', fullName);
    await prefs.setString('username', data['email']);
    await prefs.setString('phone', data['phoneNumber'] ?? '');
    await prefs.setString('dob', data['dateOfBirth']);
    await prefs.setString('address', data['address']);
    await prefs.setString('id', data['governmentId']);
    await prefs.setString('gender', data['gender']);
    await prefs.setBool('privacyMode', privacyMode);

    if (profileImagePath != null &&
        profileImagePath!.startsWith('data:image')) {
      await prefs.setString('profileImage', profileImagePath!);
      developer.log(
        'Saved profileImage to SharedPreferences: $profileImagePath',
        name: 'ProfilePage',
      );
    } else if (data['profileImage'] != null) {
      final base64Image = 'data:image/jpeg;base64,${data['profileImage']}';
      await prefs.setString('profileImage', base64Image);
      developer.log(
        'Saved server profileImage to SharedPreferences: $base64Image',
        name: 'ProfilePage',
      );
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
    nameController.dispose();
    bloodGroupController.dispose();
    super.dispose();
  }

  void logout() async {
    final bool? initialConfirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (initialConfirm == true) {
      final bool? finalConfirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Really Logout?'),
              content: const Text(
                'Do you really want to logout? This action will clear your session.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes, Logout'),
                ),
              ],
            ),
      );

      if (finalConfirm == true) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('First Name is required')));
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Last Name is required')));
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email is required')));
      return false;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return false;
    }
    final phoneText = phoneController.text.trim();
    if (phoneText.isNotEmpty &&
        !RegExp(r'^\+\d{1,3}\s\d{5,15}$').hasMatch(phoneText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid phone number (e.g., +91 12345 6789)',
          ),
        ),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (dobController.text != formattedDate) {
        setState(() {
          dobController.text = formattedDate;
        });
      }
    }
  }

  void _navigateToHomePage() {
    // Add a confirmation dialog if editing is in progress
    if (isEditing) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Unsaved Changes'),
              content: Text(
                'You have unsaved changes. Are you sure you want to leave?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _performNavigation();
                  },
                  child: Text('Leave'),
                ),
              ],
            ),
      );
    } else {
      _performNavigation();
    }
  }

  void _performNavigation() {
    final fullName =
        '${firstNameController.text} ${lastNameController.text}'.trim();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => HomePage(
              username:
                  emailController.text.isNotEmpty
                      ? emailController.text
                      : username ?? 'Guest',
              fullName: fullName.isNotEmpty ? fullName : 'Guest User',
              profileImage: profileImagePath,
            ),
      ),
    );
  }
double get iconSize => screenWidth * 0.10;
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body:
          isLoading
              ? _buildSkeletonLoading()
              : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Colors.white, // Set your desired color
                      elevation: 0,
                      pinned: true,
                      floating: false,
                      expandedHeight: 0, // No expanded height needed
                      toolbarHeight: kToolbarHeight, // Standard toolbar height
                      automaticallyImplyLeading: false,
                      flexibleSpace: Container(), // Empty flexible space
                      title: Row(
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/back.png',
                              width: iconSize,
                              height: iconSize,
                            ),
                            onPressed: _navigateToHomePage,
                            tooltip: 'Go back',
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Profile Summary',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            onPressed: logout,
                            tooltip: 'Logout',
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Card - now part of scrollable content
                      _buildProfileHeader(),
                      // Rest of your content
                      _buildProfileContent(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    final fullName =
        '${firstNameController.text} ${lastNameController.text}'.trim();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 16), // Add some top padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    buildProfileImage(),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            emailController.text,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'Patient ID: ${userCode ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProfileStat('Age', '${_calculateAge()} yrs'),
                    _buildProfileStat(
                      'Blood',
                      bloodGroupController.text.isEmpty
                          ? 'N/A'
                          : bloodGroupController.text,
                    ),
                    _buildProfileStat('Last Visit', '2 weeks'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Notice Section
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(screenWidth * 0.04),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Health Advisory',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your next check-up is due in 2 weeks. Book an appointment with your doctor soon.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Medical Records Section
            _buildSectionTitle('Medical Records'),
            _buildMedicalMenuItem(
              icon: Icons.medical_services,
              title: 'Medical History',
              subtitle: 'View your complete health records',
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Medical History'),
                        content: const Text(
                          'No records available at this time.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              },
            ),
            _buildMedicalMenuItem(
              icon: Icons.medication,
              title: 'Current Medications',
              subtitle: 'View your active prescriptions',
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Current Medications'),
                        content: const Text(
                          'No records available at this time.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              },
            ),
            _buildMedicalMenuItem(
              icon: Icons.calendar_today,
              title: 'Upcoming Appointments',
              subtitle: 'View your scheduled appointments',
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Upcoming Appointments'),
                        content: const Text(
                          'No records available at this time.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              },
            ),

            // Personal Information Section
            _buildSectionTitle('Personal Information'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  _buildEditableField(
                    label: 'First Name',
                    controller: firstNameController,
                    isEditing: isEditing,
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    label: 'Last Name',
                    controller: lastNameController,
                    isEditing: isEditing,
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    label: 'Email',
                    controller: emailController,
                    isEditing: isEditing,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    label: 'Phone Number',
                    controller: phoneController,
                    isEditing: isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    label: 'Date of Birth',
                    controller: dobController,
                    isEditing: isEditing,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    label: 'Blood Group',
                    controller: bloodGroupController,
                    isEditing: isEditing,
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    label: 'Address',
                    controller: addressController,
                    isEditing: isEditing,
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    label: 'Government ID',
                    controller: idController,
                    isEditing: isEditing,
                  ),
                  SizedBox(height: 10),
                  if (isEditing)
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items:
                          genderOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          gender = newValue;
                        });
                      },
                    )
                  else
                    _buildEditableField(
                      label: 'Gender',
                      controller: TextEditingController(
                        text: gender ?? 'Not specified',
                      ),
                      isEditing: false,
                    ),
                ],
              ),
            ),

            // Emergency Contacts (unchanged)
            _buildSectionTitle('Emergency Contacts'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.emergency, color: Colors.red),
                      title: Text('Emergency Contact 1'),
                      subtitle: Text('John Doe - -------------'),
                      trailing: isEditing ? Icon(Icons.edit) : null,
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.emergency, color: Colors.red),
                      title: Text('Emergency Contact 2'),
                      subtitle: Text('Jane Smith - +1 987 654 321'),
                      trailing: isEditing ? Icon(Icons.edit) : null,
                    ),
                  ],
                ),
              ),
            ),

            // Edit/Save Button
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: isEditing ? Colors.green : Colors.blue,
                ),
                onPressed: toggleEditing,
                child:
                    isSaving
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          isEditing ? 'SAVE PROFILE' : 'EDIT PROFILE',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  int _calculateAge() {
    try {
      final dob = DateTime.parse(dobController.text);
      final now = DateTime.now();
      return now.year -
          dob.year -
          (now.month > dob.month ||
                  (now.month == dob.month && now.day >= dob.day)
              ? 0
              : 1);
    } catch (e) {
      return 0;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenHeight * 0.03,
        screenWidth * 0.04,
        screenHeight * 0.01,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMedicalMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        SizedBox(height: 8), // Add gap above each item
        InkWell(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.blue),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: !isEditing,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon:
            onTap != null && isEditing ? Icon(Icons.calendar_today) : null,
      ),
      readOnly: !isEditing || onTap != null,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(height: screenHeight * 0.32, color: Colors.white),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: screenWidth * 0.3,
                  height: screenHeight * 0.03,
                  color: Colors.white,
                ),
                SizedBox(height: screenHeight * 0.02),
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.06,
                      color: Colors.white,
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

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Placeholder for $title page')),
    );
  }
}
