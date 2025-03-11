import 'package:flutter/material.dart';

class DoctorsListPage extends StatelessWidget {
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
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Reduced padding
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
    );
  }
}
