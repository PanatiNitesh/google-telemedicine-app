import 'package:flutter/material.dart';

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

class LabTestsPage extends StatelessWidget {
  final List<Map<String, dynamic>> tests = [
    {'name': 'Allergy Test', 'icon': Icons.science, 'booked': false},
    {'name': 'CT Scan', 'icon': Icons.medical_services, 'booked': false},
    {'name': 'Ultra Sound', 'icon': Icons.waves, 'booked': false},
    {'name': 'Blood Test', 'icon': Icons.water_drop, 'booked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text('Laboratory Tests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: tests.map((test) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
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
                  child: Icon(test['icon'], size: 30, color: Colors.blue),
                ),
                title: Text(test['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Description here...'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: Text('Book'),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.science), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.blue), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
