import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Test Results',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestResults(),
    );
  }
}

class TestResults extends StatefulWidget {
  @override
  _TestResultsState createState() => _TestResultsState();
}

class _TestResultsState extends State<TestResults> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> testResults = [
    {'type': 'Ultra Sound', 'action': 'DOWNLOAD', 'icon': Icons.health_and_safety},
    {'type': 'CT Scan', 'action': 'DOWNLOAD', 'icon': Icons.scanner},
    {'type': 'Blood Test', 'action': 'DOWNLOAD', 'icon': Icons.bloodtype},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laboratory Test Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var result in testResults)
              Card(
                elevation: 2.0,
                margin: EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(result['icon'], color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            result['type'],
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Add download functionality here
                          print('${result['type']} downloaded');
                        },
                        child: Text(result['action']),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.person, 0),
            _buildNavItem(Icons.analytics, 1),
            _buildNavItem(Icons.home, 2),
            _buildNavItem(Icons.search, 3),
            _buildNavItem(Icons.account_circle, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedIndex == index ? Colors.black12 : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: _selectedIndex == index ? Colors.black : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
