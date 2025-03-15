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
  List<Map<String, dynamic>> tests = [
    {
      'name': 'Allergy Test',
      'icon': Icons.science,
      'description': 'Identify allergic reactions and triggers.',
      'booked': false
    },
    {
      'name': 'CT Scan',
      'icon': Icons.medical_services,
      'description': 'Detailed imaging for internal diagnostics.',
      'booked': false
    },
    {
      'name': 'Ultra Sound',
      'icon': Icons.waves,
      'description': 'Non-invasive imaging using sound waves.',
      'booked': false
    },
    {
      'name': 'Blood Test',
      'icon': Icons.water_drop,
      'description': 'Analyze blood for health indicators.',
      'booked': false
    },
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
    if (_selectedIndex == index) return; // Avoid unnecessary navigation

    setState(() {
      _selectedIndex = index;
    });
    _controller.forward().then((_) => _controller.reverse());

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
          MaterialPageRoute(
              builder: (_) => const HomePage(username: 'User')),
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

  void _bookTest(int index) {
    setState(() {
      tests[index]['booked'] = !tests[index]['booked'];
    });
  }

  Widget _buildBottomNavBar() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [BoxShadow(color: Colors.grey.withAlpha(76), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -2))],
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
            decoration: BoxDecoration(color: _selectedIndex == index ? Colors.blue : Colors.transparent, shape: BoxShape.circle),
            child: Icon(icon, color: _selectedIndex == index ? Colors.white : Colors.grey),
          ),
        );
      },
    ),
    label: label,
  );
}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    final navBarHeight = screenHeight * (orientation == Orientation.portrait ? 0.12 : 0.18);

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBody: true, // Allows body to extend behind the bottom navbar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage(username: 'User')),
              );
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
          'Laboratory Tests',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          10.0, // No top padding; content starts directly below AppBar
          screenWidth * 0.04,
          navBarHeight + (screenWidth * 0.03), // Padding to avoid overlap with navbar
        ),
        child: ListView.builder(
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: screenWidth * 0.012,
                    spreadRadius: screenWidth * 0.005,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(screenWidth * 0.04),
                leading: Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Icon(
                    test['icon'],
                    size: screenWidth * 0.08,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  test['name'],
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.005),
                  child: Text(
                    test['description'],
                    style: TextStyle(fontSize: screenWidth * 0.035),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: test['booked'] ? Colors.grey : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                  onPressed: () => _bookTest(index),
                  child: Text(
                    test['booked'] ? 'Cancel' : 'Book',
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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