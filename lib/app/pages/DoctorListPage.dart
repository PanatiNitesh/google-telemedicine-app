import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart'; // Assuming this is where HomePage is defined
import 'package:flutter_project/app/pages/ProfilePage.dart'; // Add imports for navigation targets
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:logging/logging.dart'; // For Logger

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage>
    with SingleTickerProviderStateMixin {
  final _logger = Logger('DoctorsListPage');
  int _selectedIndex = 0; // Default to Doctors (can adjust based on context)
  late AnimationController _controller;
  late Animation<double> _animation;

  // Doctors data
  final List<Map<String, dynamic>> doctors = [
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
      'description': 'Caring for children’s health and well-being.',
      'image': 'assets/doctor3.png',
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
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
      case 1:
        themeColor = Colors.teal;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TestResults()));
        break;
      case 2:
        themeColor = Colors.blue;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomePage(username: 'User')));
        break;
      case 3:
        themeColor = Colors.amber;
        // Add search page navigation if available
        break;
      case 4:
        themeColor = Colors.red;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
      default:
        themeColor = Colors.blue;
    }
    _logger.info('Changed theme color to: $themeColor');
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
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
              width: 90, // Adjusted size to match home page
              height: 90, // Adjusted size
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Reduced padding
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
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced space
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
            padding: const EdgeInsets.all(12.0),
            child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[600]), // Small arrow for navigation
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14), // Maintain spacing
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/back.png',
              width: 20, // Reduced size
              height: 20, // Reduced size
            ),
          ),
        ),
        title: const Text(
          'Doctors List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            return _buildDoctorCard(doctors[index]);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(), // Add the navbar here
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
              padding: const EdgeInsets.all(15), // Larger blue circle for selected items
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

void main() {
  runApp(const MaterialApp(home: DoctorsListPage()));
}