import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:image_picker/image_picker.dart'; // For profile picture selection
import 'package:shared_preferences/shared_preferences.dart'; // For persistent storage

void main() {
  runApp(MaterialApp(
    home: const ProfilePage(),
    initialRoute: '/',
    routes: {
      '/': (context) => const PlaceholderPage(title: 'Login'),
    },
  ));
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isSaving = false;

  // Form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  String? gender; // For dropdown
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? profileImagePath; // To store the selected profile image path

  // Responsive variables
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstNameController.text = prefs.getString('firstName') ?? 'John';
      lastNameController.text = prefs.getString('lastName') ?? 'Doe';
      emailController.text = prefs.getString('email') ?? 'example@gmail.com';
      phoneController.text = prefs.getString('phone') ?? '+91 12345 6789';
      dobController.text = prefs.getString('dob') ?? '1990-01-01';
      addressController.text = prefs.getString('address') ?? '7th street - medicine road, doctor 82';
      idController.text = prefs.getString('id') ?? '9999-8888-7777-6666';
      gender = prefs.getString('gender') ?? 'Male';
      profileImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstNameController.text);
    await prefs.setString('lastName', lastNameController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('dob', dobController.text);
    await prefs.setString('address', addressController.text);
    await prefs.setString('id', idController.text);
    await prefs.setString('gender', gender ?? 'Male');
    if (profileImagePath != null) {
      await prefs.setString('profileImagePath', profileImagePath!);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    idController.dispose();
    super.dispose();
  }

  void logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void toggleEditing() async {
    if (isEditing) {
      // Validate and save
      if (_validateForm()) {
        setState(() {
          isSaving = true;
        });
        await _saveProfileData();
        setState(() {
          isEditing = false;
          isSaving = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
        }
      }
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First Name is required')),
      );
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Last Name is required')),
      );
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return false;
    }
    if (phoneController.text.trim().isEmpty || !RegExp(r'^\+\d{1,3}\s\d{5,15}$').hasMatch(phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number (e.g., +91 12345 6789)')),
      );
      return false;
    }
    if (dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date of Birth is required')),
      );
      return false;
    }
    final dob = DateTime.tryParse(dobController.text);
    if (dob == null || DateTime.now().difference(dob).inDays < 18 * 365) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be at least 18 years old')),
      );
      return false;
    }
    return true;
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!isEditing) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    if (!isEditing) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          profileImagePath = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile picture updated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
          'Profile Summary',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.04),
            child: ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0062FF),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture section
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/backshape.png',
                          width: screenWidth * 0.55,
                          height: screenWidth * 0.55,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: screenWidth * 0.55,
                            height: screenWidth * 0.55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: screenWidth * 0.02,
                                  spreadRadius: screenWidth * 0.01,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ClipOval(
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            color: Colors.transparent, // Make background transparent to show backshape
                            child: profileImagePath != null
                                ? Image.network(
                                    profileImagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      size: screenWidth * 0.15,
                                      color: Colors.black,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange[300],
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: screenWidth * 0.15,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: screenWidth * 0.08,
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: screenWidth * 0.05,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: screenWidth * 0.05,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Form fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'First Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleEditing,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEditing ? Icons.save : Icons.edit_outlined,
                                size: screenWidth * 0.045,
                                color: Colors.black,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                isEditing ? 'Save' : 'Edit',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  buildTextField(firstNameController, 'First Name'),

                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Last Name'),
                  buildTextField(lastNameController, 'Last Name'),

                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Gender'),
                  buildGenderDropdown(),

                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Email'),
                  buildTextField(emailController, 'example@gmail.com'),

                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Phone Number'),
                  buildTextField(phoneController, '+91 12345 6789'),

                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Date of Birth'),
                  buildDateField(context),

                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Full Address'),
                  buildTextField(addressController, '7th street - medicine road, doctor 82'),

                  SizedBox(height: screenHeight * 0.03),
                  buildLabel('Government/Medical ID'),
                  buildTextField(idController, '9999-8888-7777-6666'),

                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
            if (isSaving)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.045,
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return Container(
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return Container(
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: gender,
        onChanged: isEditing
            ? (String? newValue) {
                setState(() {
                  gender = newValue;
                });
              }
            : null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          border: InputBorder.none,
        ),
        items: genderOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        hint: const Text('Select Gender'),
      ),
    );
  }

  Widget buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: screenHeight * 0.06,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dobController.text.isEmpty ? 'yyyy-mm-dd' : dobController.text,
                style: TextStyle(
                  color: dobController.text.isEmpty ? Colors.grey : Colors.black,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              Icon(
                Icons.calendar_today,
                size: screenWidth * 0.05,
                color: isEditing ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ),
      ),
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