import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/ellipse.png', // Ensure this image is in your assets folder
              width: 200,
              height: 200,
            ),
          ),

          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                children: [
                  // Back Button & Profile Summary Heading
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/back.png', // Ensure 'back.png' is in the assets folder
                          width: 40, // Adjust size if necessary
                          height: 40,
                        ),
                      ),
                      SizedBox(width: 10), // Spacing between back button and heading
                      Text(
                        "Profile Summary",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Centered Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/image.png'), // Replace with actual image path
                        ),
                        Positioned(
                          right: 10, // Adjusted position
                          bottom: 10, // Adjusted position
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                            child: Icon(Icons.edit, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Input Fields
                  ProfileInputField(label: "First Name", hint: "First Name"),
                  ProfileInputField(label: "Last Name", hint: "Last Name"),
                  ProfileInputField(label: "Gender", hint: "Gender"),
                  ProfileInputField(label: "Email", hint: "example@gmail.com"),
                  ProfileInputField(label: "Phone Number", hint: "+91 12345 6789"),
                  ProfileInputField(label: "Date-Of-Birth", hint: "yyyy-mm-dd"),
                  ProfileInputField(label: "Full Address", hint: "7th street - medicine road, doctor 82"),
                  ProfileInputField(label: "Government/Medical ID Verification", hint: "9999-8888-7777-6666"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Widget for Input Fields
class ProfileInputField extends StatelessWidget {
  final String label;
  final String hint;

  ProfileInputField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
