import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  
  // Form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with example values as shown in the image
    emailController.text = 'example@gmail.com';
    phoneController.text = '+91 12345 6789';
    dobController.text = 'yyyy-mm-dd';
    addressController.text = '7th street - medicine road, doctor 82';
    idController.text = '9999-8888-7777-6666';
  }
  void logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
  @override
  void dispose() {
    // Dispose all controllers
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    idController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      body: SafeArea(
        child: Column(
          children: [
            // Transparent navigation bar with back button and logout
            Container(
                color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button using custom image
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/back.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                  
                  // Profile Summary text
                  Text(
                    'Profile Summary',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  
                  // Logout button
                  ElevatedButton(
                    onPressed: () {
                      // Logout functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0062FF),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture section with backshape.png
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background shape from assets
                          Image.asset(
                            'assets/backshape.png',
                            width: 130,
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Profile image placeholder
                          ClipOval(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.orange[300],
                              ),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Form fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'First Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Edit button matching UI
                        GestureDetector(
                          onTap: toggleEditing,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isEditing ? 'Save' : 'Edit',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    buildTextField(firstNameController, 'First Name'),
                    
                    const SizedBox(height: 16),
                    buildLabel('Last Name'),
                    buildTextField(lastNameController, 'Last Name'),
                    
                    const SizedBox(height: 16),
                    buildLabel('Gender'),
                    buildTextField(genderController, 'Gender'),
                    
                    const SizedBox(height: 16),
                    buildLabel('Email'),
                    buildTextField(emailController, 'example@gmail.com'),
                    
                    const SizedBox(height: 16),
                    buildLabel('Phone Number'),
                    buildTextField(phoneController, '+91 12345 6789'),
                    
                    const SizedBox(height: 16),
                    buildLabel('Date-Of-Birth'),
                    buildTextField(dobController, 'yyyy-mm-dd'),
                    
                    const SizedBox(height: 16),
                    buildLabel('Full Address'),
                    buildTextField(addressController, '7th street - medicine road, doctor 82'),
                    
                    const SizedBox(height: 16),
                    buildLabel('Government/Medical ID Verification'),
                    buildTextField(idController, '9999-8888-7777-6666'),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
  
  Widget buildTextField(TextEditingController controller, String hint) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.black.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}