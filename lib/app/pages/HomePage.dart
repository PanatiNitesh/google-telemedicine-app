import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/app/pages/DoctorListPage.dart';
import 'package:flutter_project/app/pages/appointmentpage.dart';
import 'package:flutter_project/app/pages/medicines_list_page.dart';
import 'package:flutter_project/app/pages/profile-page.dart';
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:flutter_project/app/pages/chat_bot.dart';
import 'package:flutter_project/app/pages/labtests.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String fullName;
  final String? profileImage;

  const HomePage({
    super.key,
    required this.username,
    required this.fullName,
    this.profileImage,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _logger = Logger('HomePage');
  int _selectedIndex = 2; // Home index
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterActive = false;
  bool _isSuggestionVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _storedProfileImage;
  String? _storedUsername;
  String? _storedFirstName;
  String? _storedLastName;
  Uint8List? _decodedProfileImage;
  bool _isProfileImageUrl = false;
  String? _firstName;
  bool _showAllDoctors = false; // New state variable

  // Expanded doctor list
  final List<Map<String, dynamic>> doctors = [
    {
    'name': 'Dr. Sarah Chen',
    'specialty': 'Rheumatologist',
    'image': 'assets/doctor1.png',
    'description': 'Experienced doctor specializing in joint and muscle conditions',
  },
  {
    'name': 'Dr. Amanda Wilson',
    'specialty': 'Dermatologist',
    'image': 'assets/doctor2.png',
    'description': 'Skin specialist with 10+ years experience',
  },
  {
    'name': 'Dr. Michael Rodriguez',
    'specialty': 'Cardiologist',
    'image': 'assets/doctor1.png',
    'description': 'Heart specialist with extensive experience',
  },
  {
    'name': 'Dr. James Patel',
    'specialty': 'Neurologist',
    'image': 'assets/doctor2.png',
    'description': 'Expert in brain and nervous system disorders',
  },
  {
    'name': 'Dr. Emily Thompson',
    'specialty': 'Pediatrician',
    'image': 'assets/doctor1.png',
    'description': 'Specialist in child healthcare',
  },
  {
    'name': 'Dr. John Doe',
    'specialty': 'Cardiologist',
    'description': 'Expert in heart diseases with 10 years of experience.',
    'image': 'assets/doctor1.png',
  },
  {
    'name': 'Dr. Jane Smith',
    'specialty': 'Dermatologist',
    'description': 'Specialist in skin and hair treatments.',
    'image': 'assets/doctor2.png',
  },
  {
    'name': 'Dr. Robert Brown',
    'specialty': 'Pediatrician',
    'description': 'Caring for children health and well-being.',
    'image': 'assets/doctor1.png',
  },
  ];
  final List<String> suggestions = [
    'Dolo - 650mg',
    'Doc2 - Dermatologist',
    'Blood - CBC',
    'Doc2 - Dermatologist',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _searchController.addListener(_onSearchChanged);

    _logger.info('Received username: ${widget.username}');
    _logger.info('Received fullName: ${widget.fullName}');
    _logger.info('Received profileImage: ${widget.profileImage}');

    _storedProfileImage = widget.profileImage;
    _logger.info('Initial _storedProfileImage: $_storedProfileImage');

    if (_storedProfileImage != null) {
      if (_storedProfileImage!.startsWith('http')) {
        _isProfileImageUrl = true;
        _logger.info('Profile image is a URL');
      } else if (_storedProfileImage!.startsWith('data:image')) {
        try {
          _decodedProfileImage = base64Decode(_storedProfileImage!.split(',')[1]);
          _logger.info('Successfully decoded profile image');
        } catch (e) {
          _logger.severe('Error decoding profile image: $e');
          _decodedProfileImage = null;
        }
      } else {
        _logger.warning('Profile image format not recognized');
      }
    }

    _loadUserSession();
    _saveUserSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSuggestionVisible = _searchController.text.isNotEmpty;
    });
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _storedUsername = widget.username;
        _storedFirstName = prefs.getString('firstName') ?? widget.fullName.split(' ').first;
        _storedLastName = prefs.getString('lastName') ?? (widget.fullName.split(' ').length > 1 ? widget.fullName.split(' ').last : '');
        _firstName = _storedFirstName;
        _storedProfileImage = widget.profileImage ?? prefs.getString('profileImage');
      });

      _logger.info('Loaded username: $_storedUsername');
      _logger.info('Loaded firstName: $_storedFirstName');
      _logger.info('Loaded lastName: $_storedLastName');
      _logger.info('Loaded profileImage: $_storedProfileImage');

      if (_storedProfileImage != null && !_isProfileImageUrl && _storedProfileImage!.startsWith('data:image')) {
        try {
          _decodedProfileImage = base64Decode(_storedProfileImage!.split(',')[1]);
          _logger.info('Successfully decoded profile image in _loadUserSession');
        } catch (e) {
          _logger.severe('Error decoding profile image in _loadUserSession: $e');
          _decodedProfileImage = null;
        }
      }
    } catch (e) {
      _logger.severe('Error loading user session: $e');
    }
  }

  Future<void> _saveUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', widget.username);
      await prefs.setString('fullName', widget.fullName);
      if (widget.profileImage != null) {
        await prefs.setString('profileImage', widget.profileImage!);
        _logger.info('Saved profileImage to SharedPreferences: ${widget.profileImage}');
      } else {
        _logger.warning('No profileImage to save in SharedPreferences');
      }
      await prefs.setBool('isLoggedIn', true);
      _logger.info('User session saved');
    } catch (e) {
      _logger.severe('Error saving user session: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward().then((_) => _controller.reverse());

    final Color themeColor;
    switch (index) {
      case 0:
        themeColor = Colors.purple;
        _logger.info('Navigating to /doctors_list');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
      case 1:
        themeColor = Colors.teal;
        _logger.info('Navigating to /test_results');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TestResults()),
        );
        break;
      case 2:
        themeColor = Colors.blue;
        break;
      case 3:
        themeColor = Colors.amber;
        _logger.info('Navigating to /search from bottom navigation');
        Navigator.of(context, rootNavigator: true).pushNamed('/search');
        break;
      case 4:
        themeColor = Colors.red;
        _logger.info('Navigating to /profile');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
      default:
        themeColor = Colors.blue;
    }
    _logger.info('Changed theme color to: $themeColor');
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      return false;
    },
    child: Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    if (_isSuggestionVisible) _buildSuggestions(),
                    const SizedBox(height: 24),
                    _buildFeatureTabs(),
                    const SizedBox(height: 24),
                    _buildDoctorsList(),
                    const SizedBox(height: 24),
                    _buildAdditionalContent(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNavBar()),
        ],
      ),
    ),
  );
}

  Widget _buildHeader() {
    _logger.info('Building header with _storedProfileImage: $_storedProfileImage');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              _firstName ?? 'User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _showNotificationDrawer,
            ),
            GestureDetector(
              onTap: () {
                _logger.info('Navigating to /profile from header');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 30,
                child: _decodedProfileImage != null
                    ? ClipOval(
                        child: Image.memory(
                          _decodedProfileImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            _logger.severe('Error loading profile image: $error, StackTrace: $stackTrace');
                            return const Icon(
                              Icons.person_outline,
                              color: Colors.black54,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: Colors.black54,
                        size: 30,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Doctors, medicines',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () => _openGoogleLens(),
              child: Image.asset(
                'assets/google_lens.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.camera_alt, size: 24);
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _performSearch(_searchController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggestion',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...suggestions.map(
            (suggestion) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(suggestion),
              onTap: () {
                _searchController.text = suggestion;
                setState(() {
                  _isSuggestionVisible = false;
                });
                _performSearch(suggestion);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    _logger.info('Searching for: $query');
    _searchController.clear();
    setState(() {
      _isSuggestionVisible = false;
    });
    FocusScope.of(context).unfocus();
    _logger.info('Navigating to /search with query: $query');
    Navigator.of(context, rootNavigator: true).pushNamed('/search', arguments: {'query': query});
  }

  void _openGoogleLens() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Lens'),
        content: const Text('Open Google Lens for visual search'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool launched = false;

              if (Platform.isAndroid) {
                const String googleLensPackage = 'com.google.ar.lens';
                try {
                  final intent = AndroidIntent(
                    action: 'android.intent.action.VIEW',
                    package: googleLensPackage,
                    data: 'https://lens.google.com/',
                  );
                  await intent.launch();
                  launched = true;
                } catch (e) {
                  _logger.severe('Error launching Google Lens app: $e');
                }
              }

              if (!launched) {
                final Uri url = Uri.parse('https://lens.google.com/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Lens is not available')),
                    );
                  }
                }
              }
            },
            child: const Text('Google Lens'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTabs() {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.person,
        'color': Colors.blue,
        'title': 'Doctors',
        'onTap': () => _navigateToPage(0),
      },
      {
        'icon': Icons.medication,
        'color': Colors.blue,
        'title': 'Medicines',
        'onTap': () => _navigateToPage(1),
      },
      {
        'icon': Icons.calendar_today,
        'color': Colors.blue,
        'title': 'Appointments',
        'onTap': () => _navigateToPage(2),
      },
      {
        'icon': Icons.science,
        'color': Colors.blue,
        'title': 'Laboratories',
        'onTap': () => _navigateToPage(3),
      },
      {
        'icon': Icons.chat_bubble_outline,
        'color': Colors.blue,
        'title': 'AI assistant',
        'onTap': () => _navigateToPage(4),
      },
      {
        'icon': Icons.science_outlined,
        'color': Colors.blue,
        'title': 'Test results',
        'onTap': () => _navigateToPage(5),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: features.map((feature) {
        return _buildFeatureItem(
          icon: feature['icon'],
          color: feature['color'],
          title: feature['title'],
          onTap: feature['onTap'],
        );
      }).toList(),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

Widget _buildDoctorsList() {
    final displayedDoctors = _showAllDoctors ? doctors : doctors.take(2).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Doctor's List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _toggleFilter,
              icon: Icon(
                Icons.filter_list,
                color: _isFilterActive ? Colors.blue : Colors.black,
              ),
              label: Text(
                'Filter',
                style: TextStyle(
                  color: _isFilterActive ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: displayedDoctors.map((doctor) => _buildDoctorCard(doctor)).toList(),
        ),
        const SizedBox(height: 10),
        if (doctors.length > 2)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showAllDoctors = !_showAllDoctors;
              });
              _logger.info('Toggled doctor list visibility: $_showAllDoctors');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              _showAllDoctors ? 'Show Less' : 'More',
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return GestureDetector(
      onTap: () {
        _logger.info('Navigating to /doctor-profile for ${doctor['name']}');
        Navigator.pushNamed(
          context,
          '/doctor-profile',
          arguments: {
            'doctorName': doctor['name'],
            'specialty': doctor['specialty'],
            'imagePath': doctor['image'],
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                doctor['image'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 50),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor['specialty'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['description'],
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton(
                onPressed: () {
                  _logger.info('Navigating to /book-appointment for ${doctor['name']}');
                  Navigator.pushNamed(
                    context,
                    '/book-appointment',
                    arguments: {
                      'doctorName': doctor['name'],
                      'specialty': doctor['specialty'],
                      'imagePath': doctor['image'],
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('Book', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildBottomNavBar() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white, // Keep the original white color
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha(76),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    margin: const EdgeInsets.all(12), // Keep the original margin
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent, // Make the BottomNavigationBar background transparent
        elevation: 0, // Remove default elevation
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.person_search, 0, 'Profile'),
          _buildNavItem(Icons.science_outlined, 1, 'Tests'),
          _buildNavItem(Icons.home, 2, 'Home'),
          _buildNavItem(Icons.search, 3, 'Search'),
          _buildNavItem(Icons.person_outline, 4, 'Account'),
        ],
      ),
    ),
  );
}

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    int index,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _selectedIndex == index ? _animation.value : 0),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _selectedIndex == index ? Colors.white : Colors.grey,
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }

  Widget _buildAdditionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Tips',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildHealthTipCard(
                'Stay Hydrated',
                'Drink 8 glasses of water daily.',
              ),
              _buildHealthTipCard(
                'Exercise Regularly',
                '30 minutes most days of the week.',
              ),
              _buildHealthTipCard(
                'Healthy Diet',
                'Include fruits and vegetables.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildHealthDataSection(),
      ],
    );
  }

  Widget _buildHealthTipCard(String title, String description) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHealthDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Health Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                _logger.info('View all health data tapped');
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHealthDataCard(
              'Weight',
              '67.98',
              'kg',
              Icons.monitor_weight_outlined,
              CustomPaint(
                size: const Size(double.infinity, 40),
                painter: LineGraphPainter(
                  points: const [
                    Offset(0, 20),
                    Offset(25, 30),
                    Offset(50, 15),
                    Offset(75, 25),
                    Offset(100, 10),
                  ],
                  lineColor: Colors.blue,
                ),
              ),
            ),
            _buildHealthDataCard(
              'Blood Oxygen',
              '93%',
              'SpO2',
              Icons.favorite_border,
              CustomPaint(
                size: const Size(double.infinity, 50),
                painter: BarChartPainter(),
              ),
            ),
            _buildHealthDataCard(
              'Step Tracker',
              '7656',
              'steps',
              Icons.directions_walk_outlined,
              CustomPaint(
                size: const Size(60, 60),
                painter: StepTrackerPainter(progress: 0.65, strokeWidth: 8.0),
              ),
            ),
            _buildEmptyHealthDataCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthDataCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Widget graph,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Expanded(child: Center(child: graph)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHealthDataCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(15),
    );
  }

  void _showNotificationDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[400],
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text('Notification ${index + 1}'),
                      subtitle: const Text(
                        'This is a notification message',
                      ),
                      trailing: Text('${index + 1}h ago'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        _logger.info('Navigating to /doctors_list');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorsListPage()),
        );
        break;
      case 1:
        _logger.info('Navigating to /medicines');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MedicinesListPage()),
        );
        break;
      case 2:
        _logger.info('Navigate to /book-appointment');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AppointmentHistoryPage()),
        );
        break;
      case 3:
        _logger.info('Navigating to /lab_tests');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LabTestsApp()),
        );
        break;
      case 4:
        _logger.info('Navigating to /ai_diagnose');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
      case 5:
        _logger.info('Navigating to /test_results');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TestResults()),
        );
        break;
      default:
        _logger.info('Navigate to feature $index');
    }
  }

  void _toggleFilter() {
    setState(() {
      _isFilterActive = !_isFilterActive;
    });
    if (_isFilterActive) {
      _showFilterOptions();
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Doctors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Specialty'),
            Wrap(
              spacing: 8,
              children: [
                'All',
                'Rheumatologist',
                'Dermatologist',
                'Cardiologist',
                'Neurologist',
              ].map((specialty) {
                return ChoiceChip(
                  label: Text(specialty),
                  selected: specialty == 'All',
                  onSelected: (selected) {
                    Navigator.pop(context);
                    _logger.info('Filter selected: $specialty');
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Availability'),
            Wrap(
              spacing: 8,
              children: ['Any time', 'Today', 'Tomorrow', 'This week'].map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: time == 'Any time',
                  onSelected: (selected) {
                    Navigator.pop(context);
                    _logger.info('Time filter selected: $time');
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class LineGraphPainter extends CustomPainter {
  final List<Offset> points;
  final Color lineColor;

  LineGraphPainter({required this.points, this.lineColor = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (points.isNotEmpty) {
      final scaledPoints = points.map((point) {
        return Offset(
          point.dx / 100 * size.width,
          size.height - (point.dy / 30 * size.height),
        );
      }).toList();

      path.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);

      for (int i = 1; i < scaledPoints.length; i++) {
        path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
      }

      canvas.drawPath(path, paint);

      final pointPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill;

      for (var point in scaledPoints) {
        canvas.drawCircle(point, 3.0, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final barWidth = size.width / 8;
    final maxHeight = size.height - 10;

    for (int i = 0; i < 6; i++) {
      final height = 10 + (i % 3 + 1) * 10;
      final x = (i + 1) * barWidth;

      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - height),
        paint..color = Colors.blue,
      );
    }

    final arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, maxHeight - 5);
    path.lineTo(size.width - 10, 5);
    path.lineTo(size.width - 15, 0);
    path.moveTo(size.width - 10, 5);
    path.lineTo(size.width - 5, 10);

    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class StepTrackerPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  StepTrackerPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2) // Updated from withOpacity
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 2 * progress,
      false,
      progressPaint,
    );

    final iconPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final iconPath = Path();
    final iconCenter = center;
    final iconSize = radius * 0.5;

    canvas.drawCircle(
      Offset(iconCenter.dx, iconCenter.dy - iconSize * 0.5),
      iconSize * 0.2,
      iconPaint,
    );

    iconPath.moveTo(iconCenter.dx, iconCenter.dy - iconSize * 0.3);
    iconPath.lineTo(iconCenter.dx, iconCenter.dy + iconSize * 0.1);

    iconPath.moveTo(
      iconCenter.dx - iconSize * 0.3,
      iconCenter.dy - iconSize * 0.1,
    );
    iconPath.lineTo(
      iconCenter.dx + iconSize * 0.3,
      iconCenter.dy - iconSize * 0.1,
    );

    iconPath.moveTo(iconCenter.dx, iconCenter.dy + iconSize * 0.1);
    iconPath.lineTo(
      iconCenter.dx - iconSize * 0.2,
      iconCenter.dy + iconSize * 0.5,
    );

    iconPath.moveTo(iconCenter.dx, iconCenter.dy + iconSize * 0.1);
    iconPath.lineTo(
      iconCenter.dx + iconSize * 0.3,
      iconCenter.dy + iconSize * 0.4,
    );

    canvas.drawPath(iconPath, iconPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}