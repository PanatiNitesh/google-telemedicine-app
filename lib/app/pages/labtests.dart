import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart'; // Update with your actual path

void main() {
  runApp(LabTestsApp());
}

class LabTestsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LabTestsPage(),
    );
  }
}

class LabTestsPage extends StatefulWidget {
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
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color:
                    _selectedIndex == index ? Colors.blue : Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD), // Dark gray background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: GestureDetector(
            onTap: () {
              // Back button navigates to HomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(username: 'User')),
              );
            },
            child: Image.asset(
              'assets/back.png', // Your custom back button asset
              width: 20,
              height: 20,
            ),
          ),
        ),
        title: Text(
          'Laboratory Tests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      // Reduced top padding further to bring the test boxes up
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
        child: ListView(
          children: tests.map((test) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Remove extra padding by using FittedBox to fill the container
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(test['icon'], color: Colors.blue),
                  ),
                ),
                title: Text(test['name'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Description here...'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: Text('Book'),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

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
