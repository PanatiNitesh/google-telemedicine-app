import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _consentGiven = false;

  // Dropdown controllers
  String? _selectedCountry;

  // List of all countries
  final List<String> _countries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda',
    'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain',
    'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia',
    'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso',
    'Burundi', 'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'Central African Republic',
    'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Congo (Brazzaville)',
    'Congo (Kinshasa)', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus', 'Czech Republic',
    'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt',
    'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia',
    'Fiji', 'Finland', 'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana',
    'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti',
    'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland',
    'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati',
    'Kosovo', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia',
    'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar', 'Malawi',
    'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania',
    'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro',
    'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nauru', 'Nepal', 'Netherlands',
    'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia',
    'Norway', 'Oman', 'Pakistan', 'Palau', 'Panama', 'Papua New Guinea', 'Paraguay',
    'Peru', 'Philippines', 'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda',
    'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa',
    'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia',
    'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands',
    'Somalia', 'South Africa', 'South Korea', 'South Sudan', 'Spain', 'Sri Lanka',
    'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria', 'Taiwan', 'Tajikistan',
    'Tanzania', 'Thailand', 'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago',
    'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda', 'Ukraine',
    'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan',
    'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
  ];

  // Map of countries to their states/provinces (simplified subset)
  final Map<String, List<String>> _countryStates = {
    'United States': [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut',
      'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
      'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan',
      'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
      'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
      'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
      'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia',
      'Wisconsin', 'Wyoming',
    ],
    'Canada': [
      'Alberta', 'British Columbia', 'Manitoba', 'New Brunswick', 'Newfoundland and Labrador',
      'Nova Scotia', 'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan',
    ],
    'India': [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat',
      'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh',
      'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh',
      'Uttarakhand', 'West Bengal',
    ],
    // Add more countries and states as needed
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
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
                          const Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
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

                                _buildLabel('Phone Number'),
                                _buildTextField('+91 12345 6789'),
                                const SizedBox(height: 15),

                                _buildLabel('Date-Of-Birth'),
                                _buildDateField(),
                                const SizedBox(height: 15),

                                _buildLabel('Full Address'),
                                _buildTextField('7th street - medicine road, doctor 82'),
                                const SizedBox(height: 15),

                                // Country and State in one row with Autocomplete
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Country'),
                                          _buildCountryAutocomplete(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('State'),
                                          _buildStateAutocomplete(),
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
                                        // Navigate to SuccessPage
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SuccessPage()),
                                        );
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
                                const SizedBox(height: 100), // Extra space to ensure scrolling
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Fixed "Or Sign-In with" section at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSocialSignInSection(),
          ),
        ],
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
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              // Update the text field with selected date (format as needed)
            });
          }
        },
      ),
    );
  }

  Widget _buildCountryAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _countries.where((country) {
          return country.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        setState(() {
          _selectedCountry = selection;
          // Reset state when country changes
        });
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              hintText: 'Search Country',
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a country';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildStateAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty || _selectedCountry == null) {
          return const Iterable<String>.empty();
        }
        return (_countryStates[_selectedCountry] ?? []).where((state) {
          return state.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        setState(() {
          // Update state selection
        });
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              hintText: 'Search State',
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _selectedCountry != null ? 'Please select a state' : null;
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildSocialSignInSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
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
        child: Image.asset(
          imagePath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $imagePath, Error: $error');
            return Icon(
              imagePath.contains('google') ? Icons.g_mobiledata :
              imagePath.contains('microsoft') ? Icons.window :
              Icons.apple,
              size: 24,
            );
          },
        ),
      ),
    );
  }
}

// Success Page
class SuccessPage extends StatefulWidget {
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to /home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with blue triangle
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: TrianglePainter(),
                  ),
                ),
                const SizedBox(height: 200), // Space to center content
              ],
            ),
          ),
          // Centered success content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Account created successfully',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Fixed "Or Sign-In with" section at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSocialSignInSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSignInSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
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
        child: Image.asset(
          imagePath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $imagePath, Error: $error');
            return Icon(
              imagePath.contains('google') ? Icons.g_mobiledata :
              imagePath.contains('microsoft') ? Icons.window :
              Icons.apple,
              size: 24,
            );
          },
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