import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart'; // Adjust import paths as needed
import 'package:flutter_project/app/pages/profile-page.dart';
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:logging/logging.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage>
    with SingleTickerProviderStateMixin {
  final _logger = Logger('DoctorsListPage');
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> doctors = [
    {
    'name': 'Dr. Sarah Chen',
    'specialty': 'Rheumatologist',
    'image': 'assets/doctor1.png',
    'description': 'Experienced doctor specializing in joint and muscle conditions',
  },
  {
    'name': 'Dr. Michael Rodriguez',
    'specialty': 'Dermatologist',
    'image': 'assets/doctor2.png',
    'description': 'Skin specialist with 10+ years experience',
  },
  {
    'name': 'Dr. Amanda Wilson',
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
        break;
      case 1:
        themeColor = Colors.teal;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TestResults()));
        break;
      case 2:
        themeColor = Colors.blue;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomePage(username: '', fullName: '',)));
        break;
      case 3:
        themeColor = Colors.amber;
        // Add search page navigation if available
        break;
      case 4:
        themeColor = Colors.red;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
        break;
      default:
        themeColor = Colors.blue;
    }
    _logger.info('Changed theme color to: $themeColor');
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, double screenWidth, double screenHeight) {
    // Define text styles
    final textStyleName = TextStyle(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.bold,
    );
    final textStyleSpecialty = TextStyle(
      color: Colors.grey[600],
      fontSize: screenWidth * 0.035,
    );
    final textStyleDescription = TextStyle(fontSize: screenWidth * 0.03);

    // Set a fixed aspect ratio for the image (e.g., 1:1 or 4:3)
    const double aspectRatio = 1.0; // Square image
    final imageHeight = screenHeight * 0.15; // Fixed height for consistency
    final imageWidth = imageHeight * aspectRatio;

    return GestureDetector(
    onTap: () {
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
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: screenWidth * 0.012,
              spreadRadius: screenWidth * 0.005,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.03),
                bottomLeft: Radius.circular(screenWidth * 0.03),
              ),
              child: Image.asset(
                doctor['image'],
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  _logger.warning('Failed to load image ${doctor['image']}: $error');
                  return Container(
                    width: imageWidth,
                    height: imageHeight,
                    color: Colors.grey[300],
                    child: Icon(Icons.person, size: imageWidth * 0.4, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: textStyleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doctor['specialty'],
                      style: textStyleSpecialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      doctor['description'],
                      style: textStyleDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Icon(
                Icons.arrow_forward_ios,
                size: screenWidth * 0.045,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/back.png',
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.arrow_back,
                size: screenWidth * 0.05,
              ),
            ),
          ),
        ),
        title: Text(
          'Doctors List',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            return _buildDoctorCard(doctors[index], screenWidth, screenHeight);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _buildNavItem(Icons.person, 0, 'Profile'),
            _buildNavItem(Icons.science_outlined, 1, 'Tests'),
            _buildNavItem(Icons.home, 2, 'Home'),
            _buildNavItem(Icons.search, 3, 'Search'),
            _buildNavItem(Icons.person_outline, 4, 'Account'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index, String label) {
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
}