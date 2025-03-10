import 'package:flutter/material.dart';

class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Doctor's List",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
 
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality here
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDoctorCard("Doctor-1", "Rheumatologist"),
          _buildDoctorCard("Doctor-2", "Dermatologist"),
          _buildDoctorCard("Doctor-3", "Dermatologist"),
          _buildDoctorCard("Doctor-4", "Dermatologist"),
          _buildDoctorCard("Doctor-5", "Dermatologist"),
          _buildDoctorCard("Doctor-6", "Dermatologist"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
        onTap: (index) {
          // Handle bottom navigation bar taps
          _handleBottomNavigationTap(context, index);
        },
      ),
    );
  }

  // Doctor Card Widget with Icon
  Widget _buildDoctorCard(String name, String specialization) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Doctor Icon
            const Icon(
              Icons.medical_services,
              size: 40,
              color: Colors.blue,
            ),
            const SizedBox(width: 16), // Add spacing between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    specialization,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search Dialog
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search Doctors"),
          content: const TextField(
            decoration: InputDecoration(
              hintText: "Search by name or specialization",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Add search logic here
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Search"),
            ),
          ],
        );
      },
    );
  }

  // Handle Bottom Navigation Bar Taps
  void _handleBottomNavigationTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to Home Page
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigate to Doctor List Page (current page)
        break;
      case 2:
        // Navigate to Search Page (or show search dialog)
        _showSearchDialog(context);
        break;
      case 3:
        // Navigate to Profile Page
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}