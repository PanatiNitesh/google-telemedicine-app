import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _consentGiven = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Blue triangle design in top-left corner
            Container(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: TrianglePainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 200),
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('First Name'),
                        _buildTextField('First Name'),
                        const SizedBox(height: 15),
                        
                        _buildLabel('Last Name'),
                        _buildTextField('Last Name'),
                        const SizedBox(height: 15),
                        
                        _buildLabel('Gender'),
                        _buildTextField('Gender'),
                        const SizedBox(height: 15),
                        
                        _buildLabel('Email'),
                        _buildTextField('example@gmail.com'),
                        
                        // Social sign-in options
                        _buildSocialSignInSection(),
                        
                        _buildLabel('Phone Number'),
                        _buildTextField('+91 12345 6789'),
                        const SizedBox(height: 15),
                        
                        _buildLabel('Date-Of-Birth'),
                        _buildDateField(),
                        const SizedBox(height: 15),
                        
                        _buildLabel('Full Address'),
                        _buildTextField('7th street - medicine road, doctor 82'),
                        const SizedBox(height: 15),
                        
                        // Country and State in one row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Country'),
                                  _buildDropdownField('Country'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('State'),
                                  _buildDropdownField('State'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        _buildLabel('Government/Medical ID Verification'),
                        _buildTextField('9999-8888-7777-6666'),
                        const SizedBox(height: 20),
                        
                        // Profile Image Section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle image upload
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Upload Image'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildLabel('Create Password'),
                        _buildTextField('Password', isPassword: true),
                        const SizedBox(height: 20),
                        
                        // Consent checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _consentGiven,
                              onChanged: (value) {
                                setState(() {
                                  _consentGiven = value ?? false;
                                });
                              },
                            ),
                            const Text('Consent & Agreements'),
                          ],
                        ),
                        
                        // Dots indicator
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == 0 ? Colors.blue : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Done button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate() && _consentGiven) {
                                // Navigate to next screen or process form
                                Navigator.pushReplacementNamed(context, '/home');
                              } else {
                                // Show error or prompt for consent
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill all required fields and give consent'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'yyyy-mm-dd',
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date of birth is required';
          }
          return null;
        },
        onTap: () async {
          // Show date picker
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            // Update the text field with selected date
          }
        },
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          border: InputBorder.none,
        ),
        hint: Text(hint),
        items: const [], // Add your dropdown items here
        onChanged: (value) {},
        icon: const Icon(Icons.arrow_drop_down),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSocialSignInSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 255, 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Or Sign-In with'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton('assets/google.png', () {
                // Handle Google sign-in
              }),
              const SizedBox(width: 15),
              _buildSocialButton('assets/microsoft.png', () {
                // Handle Microsoft sign-in
              }),
              const SizedBox(width: 15),
              _buildSocialButton('assets/apple.png', () {
                // Handle Apple sign-in
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          // Use placeholder icons - you should replace with actual images
          imagePath.contains('google') ? Icons.g_mobiledata : 
          imagePath.contains('microsoft') ? Icons.window : 
          Icons.apple,
          size: 24,
        ),
      ),
    );
  }
}

// Custom painter for the blue triangle background
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    // Add the curved shapes
    final secondaryPaint = Paint()
      ..color = Colors.blue.withAlpha(51)
      ..style = PaintingStyle.fill;
    
    final curvePath1 = Path();
    curvePath1.moveTo(size.width * 0.5, size.height * 0.3);
    curvePath1.quadraticBezierTo(
      size.width * 0.7, size.height * 0.1,
      size.width, size.height * 0.2,
    );
    curvePath1.lineTo(size.width, 0);
    curvePath1.lineTo(size.width * 0.4, 0);
    curvePath1.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(curvePath1, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}