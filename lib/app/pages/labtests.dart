import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart'; // Update with your actual path

void main() {
  runApp(const LabTestsApp());
}

class LabTestsApp extends StatelessWidget {
  const LabTestsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LabTestsPage(),
    );
  }
}

class LabTestsPage extends StatefulWidget {
  const LabTestsPage({super.key});

  @override
  _LabTestsPageState createState() => _LabTestsPageState();
}

class _LabTestsPageState extends State<LabTestsPage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> tests = [
    {'name': 'Allergy Test', 'icon': Icons.science, 'booked': false},
    {'name': 'CT Scan', 'icon': Icons.medical_services, 'booked': false},
    {'name': 'Ultra Sound', 'icon': Icons.waves, 'booked': false},
    {'name': 'Blood Test', 'icon': Icons.water_drop, 'booked': false},
  ];

  int _selectedIndex = 1; // LabTests page is at index 1
  late AnimationController _controller;
  late Animation<double> _animation;

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
    _controller.forward().then((_) {
      _controller.reverse();
    });

    // Update navigation links as needed
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PlaceholderPage(title: "Profile")),
        );
        break;
      case 1:
        // Already on LabTestsPage
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PlaceholderPage(title: "Home")),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PlaceholderPage(title: "Search")),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PlaceholderPage(title: "Settings")),
        );
        break;
    }
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index, String label) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _selectedIndex == index ? _animation.value : 0),
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              decoration: BoxDecoration(
                color:
                    _selectedIndex == index ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: MediaQuery.of(context).size.width * 0.06,
                color: _selectedIndex == index ? Colors.white : Colors.grey,
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      margin: EdgeInsets.all(screenWidth * 0.02),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD), // Dark gray background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(username: 'User')),
              );
            },
            child: Image.asset(
              'assets/back.png',
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
            ),
          ),
        ),
        title: Text(
          'Laboratory Tests',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          screenHeight * 0.06, // Reduced top padding
          screenWidth * 0.04,
          screenWidth * 0.04,
        ),
        child: ListView(
          children: tests.map((test) {
            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.015), // Reduced margin
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: screenWidth * 0.01,
                    spreadRadius: screenWidth * 0.005,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(screenWidth * 0.03), // Reduced padding
                leading: Container(
                  width: screenWidth * 0.1, // Reduced width
                  height: screenWidth * 0.1, // Reduced height
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(test['icon'],
                        size: screenWidth * 0.07, color: Colors.blue), // Reduced icon size
                  ),
                ),
                title: Text(
                  test['name'],
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Description here...',
                  style: TextStyle(fontSize: screenWidth * 0.03), // Reduced font size
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008, // Reduced padding
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Book',
                    style: TextStyle(fontSize: screenWidth * 0.03), // Reduced font size
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
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