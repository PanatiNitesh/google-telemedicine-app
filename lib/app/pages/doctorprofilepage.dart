import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/appointmentpage.dart'; // Import Appointment model

class DoctorProfilePage extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String imagePath;

  const DoctorProfilePage({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.imagePath,
  });

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  int _selectedTabIndex = 0;
  final List<String> _tabLabels = ['Feedback', 'Docs', 'About'];

  // Mock data for reviews
  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Vedanth',
      'rating': '5.0',
      'date': '19 May 2024',
      'comment': 'Dr. John Doe was very professional and caring. Highly recommend!',
    },
    {
      'name': 'Mithun',
      'rating': '5.0',
      'date': '19 June 2024',
      'comment': 'Excellent experience! The doctor explained everything clearly.',
    },
    {
      'name': 'Priya Sharma',
      'rating': '4.8',
      'date': '10 July 2024',
      'comment': 'Very knowledgeable and attentive. The appointment was smooth.',
    },
    {
      'name': 'Amit Patel',
      'rating': '5.0',
      'date': '25 August 2024',
      'comment': 'Best doctor I’ve ever visited. Truly cares about patients.',
    },
  ];

  // Mock data for documents
  final List<Map<String, dynamic>> documents = [
    {
      'title': 'Medical Certificate',
      'date': '15 March 2024',
      'type': 'PDF',
    },
    {
      'title': 'Prescription - 2024',
      'date': '20 June 2024',
      'type': 'PDF',
    },
    {
      'title': 'Lab Report',
      'date': '10 August 2024',
      'type': 'PDF',
    },
  ];

  // Mock data for About section
  final Map<String, dynamic> aboutDoctor = {
    'bio':
        'Dr. John Doe is a highly experienced Cardiologist with over 10 years of practice. He specializes in heart diseases and has a passion for helping patients achieve optimal health. Dr. Doe is known for his compassionate approach and dedication to patient care.',
    'education': [
      'MBBS - University of Medical Sciences, 2010',
      'MD in Cardiology - National Heart Institute, 2014',
    ],
    'awards': [
      'Best Cardiologist Award - 2020',
      'Excellence in Patient Care - 2022',
    ],
    'languages': ['English', 'Hindi', 'Spanish'],
  };

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
          'Doctor Profile',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.black.withOpacity(0.6),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: Icon(
                  Icons.home,
                  size: screenWidth * 0.07,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea( // Wrap the body in SafeArea
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Removed the SizedBox since SafeArea handles the spacing
              // Doctor Info Section (Centered)
              Column(
                children: [
                  // Doctor Image
                  Container(
                    width: screenWidth * 0.35,
                    height: screenWidth * 0.35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/doctor1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Doctor Details
                  Text(
                    widget.doctorName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.specialty,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '5.0',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: screenWidth * 0.04,
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '(100 reviews)',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Distance and Fees
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: screenWidth * 0.04,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '80m',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      // Icon(
                      //   Icons.price_check,
                      //   color: Colors.grey,
                      //   size: screenWidth * 0.04,
                      // ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        'Fees - ₹350',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Book Button
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to BookAppointmentPage and wait for the result
                      final result = await Navigator.pushNamed(
                        context,
                        '/book-appointment',
                        arguments: {
                          'doctorName': widget.doctorName,
                          'specialty': widget.specialty,
                          'imagePath': widget.imagePath,
                        },
                      );

                      // If an appointment was returned, pass it back to AppointmentHistoryPage
                      if (result != null && result is Appointment) {
                        Navigator.pop(context, result);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
                    ),
                    child: Text(
                      'Book',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              // Stats Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(context, 'Visits', '5.8k', Icons.home),
                    SizedBox(width: screenWidth * 0.03),
                    _buildStatCard(context, 'Patients', '4.2k', Icons.people),
                    SizedBox(width: screenWidth * 0.03),
                    _buildStatCard(context, 'Experience', '8 years', Icons.work),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Tab Navigation
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Container(
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                  ),
                  child: Row(
                    children: List.generate(
                      _tabLabels.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == index
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(screenWidth * 0.06),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tabLabels[index],
                              style: TextStyle(
                                color: _selectedTabIndex == index
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Tab Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: screenWidth * 0.012,
              spreadRadius: screenWidth * 0.005,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: screenWidth * 0.05, color: Colors.grey),
            SizedBox(height: screenHeight * 0.01),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    switch (_selectedTabIndex) {
      case 0: // Feedback
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Review',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ...reviews.map((review) => Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: _buildReviewCard(
                    review['name'],
                    review['rating'],
                    review['date'],
                    review['comment'],
                  ),
                )),
          ],
        );
      case 1: // Docs
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ...documents.map((doc) => Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: _buildDocumentCard(
                    doc['title'],
                    doc['date'],
                    doc['type'],
                  ),
                )),
          ],
        );
      case 2: // About
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Doctor',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: screenWidth * 0.012,
                    spreadRadius: screenWidth * 0.005,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biography',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    aboutDoctor['bio'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Education',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  ...aboutDoctor['education'].map<Widget>((edu) => Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.005),
                        child: Text(
                          '• $edu',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[800],
                          ),
                        ),
                      )).toList(),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Awards',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  ...aboutDoctor['awards'].map<Widget>((award) => Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.005),
                        child: Text(
                          '• $award',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[800],
                          ),
                        ),
                      )).toList(),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Languages',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    aboutDoctor['languages'].join(', '),
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReviewCard(String name, String rating, String date, String comment) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
          // Profile picture placeholder
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  children: [
                    Text(
                      rating,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String title, String date, String type) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: screenWidth * 0.012,
            spreadRadius: screenWidth * 0.005,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            size: screenWidth * 0.06,
            color: Colors.grey,
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  'Date: $date',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.005,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}