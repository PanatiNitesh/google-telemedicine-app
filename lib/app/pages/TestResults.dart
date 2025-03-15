import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart'; // Update with your actual path
import 'package:flutter_project/app/pages/profile-page.dart'; // Update with your actual path
import 'dart:math'; // For simulating download failure

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Test Results',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestResults(),
    );
  }
}

class TestResults extends StatefulWidget {
  const TestResults({super.key});

  @override
  _TestResultsState createState() => _TestResultsState();
}

class _TestResultsState extends State<TestResults> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // TestResults is at index 1
  List<Map<String, dynamic>> testResults = [
    {
      'type': 'Ultra Sound',
      'description': 'Non-invasive imaging using sound waves.',
      'date': '2025-03-10',
      'action': 'DOWNLOAD',
      'downloaded': false,
      'icon': Icons.waves,
    },
    {
      'type': 'CT Scan',
      'description': 'Detailed imaging for internal diagnostics.',
      'date': '2025-03-08',
      'action': 'DOWNLOAD',
      'downloaded': false,
      'icon': Icons.medical_services,
    },
    {
      'type': 'Blood Test',
      'description': 'Analyze blood for health indicators.',
      'date': '2025-03-05',
      'action': 'DOWNLOAD',
      'downloaded': false,
      'icon': Icons.water_drop,
    },
  ];

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

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage()),
        );
        break;
      case 1:
        // Already on TestResults page
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(username: 'User')),
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
          MaterialPageRoute(builder: (_) => ProfilePage()),
        );
        break;
    }
  }

  void _downloadResult(int index) {
    // Simulate a download with a 20% chance of failure
    bool success = Random().nextDouble() > 0.2; // 80% success rate

    if (success) {
      setState(() {
        testResults[index]['downloaded'] = true;
        testResults[index]['action'] = 'VIEW';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${testResults[index]['type']} downloaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download ${testResults[index]['type']}. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewResult(int index) {
    // Simulate viewing the downloaded result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${testResults[index]['type']} result...')),
    );
  }

  Widget _buildBottomNavBar(double screenWidth, double navBarHeight) {
    return Container(
      height: navBarHeight,
      margin: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76),
            spreadRadius: screenWidth * 0.002,
            blurRadius: screenWidth * 0.025,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.person, 0, 'Profile', screenWidth),
          _buildNavItem(Icons.science_outlined, 1, 'Tests', screenWidth),
          _buildNavItem(Icons.home, 2, 'Home', screenWidth),
          _buildNavItem(Icons.search, 3, 'Search', screenWidth),
          _buildNavItem(Icons.person_outline, 4, 'Account', screenWidth),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label, double screenWidth) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _selectedIndex == index ? _animation.value : 0),
            child: CircleAvatar(
              radius: screenWidth * 0.06,
              backgroundColor: _selectedIndex == index ? Colors.blue : Colors.transparent,
              child: Icon(
                icon,
                size: screenWidth * 0.06,
                color: _selectedIndex == index ? Colors.white : Colors.grey,
              ),
            ),
          );
        },
      ),
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04), // Match LabTestsPage
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(username: 'User')),
              );
            },
            child: Image.asset(
              'assets/back.png',
              width: screenWidth * 0.05, // Match LabTestsPage
              height: screenWidth * 0.05, // Match LabTestsPage
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.arrow_back,
                size: screenWidth * 0.05, // Match LabTestsPage
              ),
            ),
          ),
        ),
        title: Text(
          'Laboratory Test Results',
          style: TextStyle(
            fontSize: screenWidth * 0.06, // Match LabTestsPage
            fontWeight: FontWeight.w500, // Match LabTestsPage
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          0.0, // Match LabTestsPage (start below AppBar)
          screenWidth * 0.04,
          navBarHeight + (screenWidth * 0.03), // Match LabTestsPage
        ),
        child: ListView.builder(
          itemCount: testResults.length,
          itemBuilder: (context, index) {
            final result = testResults[index];
            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02), // Match LabTestsPage
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
                contentPadding: EdgeInsets.all(screenWidth * 0.04), // Match LabTestsPage
                leading: Container(
                  width: screenWidth * 0.12, // Match LabTestsPage
                  height: screenWidth * 0.12, // Match LabTestsPage
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Icon(
                    result['icon'],
                    size: screenWidth * 0.08,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  result['type'],
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Match LabTestsPage
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.005),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['description'],
                        style: TextStyle(fontSize: screenWidth * 0.035), // Match LabTestsPage
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Date: ${result['date']}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: result['downloaded'] ? Colors.grey : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04, // Match LabTestsPage
                      vertical: screenHeight * 0.015, // Match LabTestsPage
                    ),
                  ),
                  onPressed: () {
                    if (result['downloaded']) {
                      _viewResult(index);
                    } else {
                      _downloadResult(index);
                    }
                  },
                  child: Text(
                    result['action'],
                    style: TextStyle(fontSize: screenWidth * 0.035), // Match LabTestsPage
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(screenWidth, navBarHeight),
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