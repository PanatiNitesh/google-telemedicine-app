import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegisterPage(),
      routes: {
        '/home': (context) => const Scaffold(body: Center(child: Text('Home Page'))),
      },
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _consentGiven = false;
  bool isLoading = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _govMedicalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedCountry;
  String? _selectedState;
  File? _profileImageFile;
  Uint8List? _profileImageBytes;

  // Dynamic backend URL
  final String _backendUrl = kIsWeb
      ? 'http://localhost:5000/api/register' // For web
      : (Platform.isAndroid && !kDebugMode)
          ? 'http://192.168.1.x:5000/api/register' // Replace with your machine’s IP for physical device
          : 'http://10.0.2.2:5000/api/register'; // For emulator

  final ImagePicker _picker = ImagePicker();

  final List<String> countries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados',
    'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cambodia',
    'Cameroon', 'Canada', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Congo, Democratic Republic of the', 'Congo, Republic of the', 'Costa Rica', 'Croatia',
    'Cuba', 'Cyprus', 'Czech Republic', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'East Timor', 'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia',
    'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti',
    'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Korea, North',
    'Korea, South', 'Kosovo', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar', 'Malawi', 'Malaysia',
    'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar', 'Namibia',
    'Nauru', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru',
    'Philippines', 'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe',
    'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan',
    'Suriname', 'Sweden', 'Switzerland', 'Syria', 'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda',
    'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
  ];

  final Map<String, List<String>> countryStates = {
    'United States': [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
      'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
      'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
      'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
      'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
    ],
    'India': [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
      'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
    ],
    // Add other countries as needed
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _dateOfBirthController.dispose();
    _fullAddressController.dispose();
    _govMedicalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      try {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _profileImageBytes = bytes;
          });
          developer.log('Web image selected, bytes length: ${bytes.length}', name: 'RegisterPage');
        } else {
          final String targetPath = '${image.path}_compressed.jpg';
          final compressedImage = await FlutterImageCompress.compressAndGetFile(
            image.path,
            targetPath,
            quality: 85,
            format: CompressFormat.jpeg,
          );
          setState(() {
            _profileImageFile = compressedImage != null ? File(compressedImage.path) : File(image.path);
          });
          developer.log('Image path: ${_profileImageFile!.path}', name: 'RegisterPage');
        }
      } catch (e) {
        developer.log('Error processing image: $e', name: 'RegisterPage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error processing image: $e')));
        }
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _consentGiven) {
      setState(() {
        isLoading = true;
      });

      try {
        // Ping server
        final pingUrl = _backendUrl.replaceAll('/api/register', '/ping');
        final pingResponse = await http.get(Uri.parse(pingUrl)).timeout(const Duration(seconds: 5));
        if (pingResponse.statusCode != 200) {
          throw Exception('Server ping failed: ${pingResponse.statusCode} - ${pingResponse.body}');
        }
        developer.log('Server ping successful: ${pingResponse.body}', name: 'RegisterPage');

        var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));

        // Add form fields
        request.fields['firstName'] = _firstNameController.text;
        request.fields['lastName'] = _lastNameController.text;
        request.fields['gender'] = _genderController.text;
        request.fields['email'] = _emailController.text;
        request.fields['phoneNumber'] = _phoneNumberController.text;
        request.fields['dateOfBirth'] = _dateOfBirthController.text;
        request.fields['address'] = _fullAddressController.text;
        request.fields['country'] = _selectedCountry ?? '';
        request.fields['state'] = _selectedState ?? '';
        request.fields['governmentId'] = _govMedicalIdController.text;
        request.fields['password'] = _passwordController.text;

        // Add profile image
        if (_profileImageFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'profileImage',
            _profileImageFile!.path,
            contentType: http_parser.MediaType('image', 'jpeg'),
          ));
          developer.log('Image file added: ${_profileImageFile!.path}', name: 'RegisterPage');
        } else if (_profileImageBytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'profileImage',
            _profileImageBytes!,
            contentType: http_parser.MediaType('image', 'jpeg'),
            filename: 'profile.jpg',
          ));
          developer.log('Image bytes added: ${_profileImageBytes!.length} bytes', name: 'RegisterPage');
        }

        developer.log('Sending request to: $_backendUrl', name: 'RegisterPage');
        var response = await request.send().timeout(const Duration(seconds: 60));
        var responseData = await http.Response.fromStream(response);

        developer.log('Response: ${response.statusCode} - ${responseData.body}', name: 'RegisterPage');

        final jsonResponse = jsonDecode(responseData.body);
        if (response.statusCode == 201 && jsonResponse['success']) {
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessPage()));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'] ?? 'Registration failed')),
            );
          }
        }
      } on TimeoutException catch (e) {
        developer.log('Timeout: $e', name: 'RegisterPage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server timed out. Check your network or server status.')),
          );
        }
      } catch (e) {
        developer.log('Error: $e', name: 'RegisterPage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields and give consent')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: CustomPaint(painter: TrianglePainter()),
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
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('First Name'),
                                _buildTextField('First Name', controller: _firstNameController),
                                const SizedBox(height: 15),
                                _buildLabel('Last Name'),
                                _buildTextField('Last Name', controller: _lastNameController),
                                const SizedBox(height: 15),
                                _buildLabel('Gender'),
                                _buildTextField('Gender', controller: _genderController),
                                const SizedBox(height: 15),
                                _buildLabel('Email'),
                                _buildTextField('example@gmail.com', controller: _emailController),
                                const SizedBox(height: 15),
                                _buildLabel('Phone Number'),
                                _buildTextField('+91 12345 6789', controller: _phoneNumberController),
                                const SizedBox(height: 15),
                                _buildLabel('Date-Of-Birth'),
                                _buildDateField(),
                                const SizedBox(height: 15),
                                _buildLabel('Full Address'),
                                _buildTextField('7th street - medicine road, doctor 82', controller: _fullAddressController),
                                const SizedBox(height: 15),
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
                                _buildTextField('9999-8888-7777-6666', controller: _govMedicalIdController),
                                const SizedBox(height: 20),
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
                                        child: _profileImageFile != null || _profileImageBytes != null
                                            ? ClipOval(
                                                child: _profileImageFile != null
                                                    ? Image.file(_profileImageFile!, width: 100, height: 100, fit: BoxFit.cover)
                                                    : Image.memory(_profileImageBytes!, width: 100, height: 100, fit: BoxFit.cover),
                                              )
                                            : const Icon(Icons.person_outline, size: 50, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: _pickImage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade300,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: const Text('Upload Image'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildLabel('Create Password'),
                                _buildTextField('Password', controller: _passwordController, isPassword: true),
                                const SizedBox(height: 20),
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
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(3, (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == 0 ? Colors.blue : Colors.grey,
                                      ),
                                    )),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: Colors.blue)
                                      : ElevatedButton(
                                          onPressed: _register,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            minimumSize: const Size(200, 50),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          ),
                                          child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
                                        ),
                                ),
                                const SizedBox(height: 100),
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
        ),
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
        controller: _dateOfBirthController,
        decoration: InputDecoration(
          hintText: 'yyyy-mm-dd',
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Date of birth is required' : null,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _dateOfBirthController.text = picked.toString().split(' ')[0];
            });
          }
        },
      ),
    );
  }

  Widget _buildCountryAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return countries.where((country) => country.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        setState(() {
          _selectedCountry = selection;
          _selectedState = null;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) => Container(
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(25)),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search Country',
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: InputBorder.none,
          ),
          validator: (value) => value == null || value.isEmpty ? 'Please select a country' : null,
        ),
      ),
    );
  }

  Widget _buildStateAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty || _selectedCountry == null) return const Iterable<String>.empty();
        return (countryStates[_selectedCountry] ?? []).where((state) => state.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) => setState(() => _selectedState = selection),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) => Container(
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(25)),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search State',
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: InputBorder.none,
          ),
          validator: (value) => _selectedCountry != null && (value == null || value.isEmpty) ? 'Please select a state' : null,
        ),
      ),
    );
  }

  Widget _buildSocialSignInSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(76), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -1))],
      ),
      child: Column(
        children: [
          const Text('Or Sign-In with'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton('assets/google.png', () {}),
              const SizedBox(width: 15),
              _buildSocialButton('assets/microsoft.png', () {}),
              const SizedBox(width: 15),
              _buildSocialButton('assets/apple.png', () {}),
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
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
        child: Image.asset(
          imagePath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            developer.log('Error loading image: $imagePath, Error: $error', name: 'RegisterPage');
            return Icon(
              imagePath.contains('google') ? Icons.g_mobiledata : imagePath.contains('microsoft') ? Icons.window : Icons.apple,
              size: 24,
            );
          },
        ),
      ),
    );
  }
}

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  SuccessPageState createState() => SuccessPageState();
}

class SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(height: 200, width: double.infinity, child: CustomPaint(painter: TrianglePainter())),
                const SizedBox(height: 200),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text('Account created successfully', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
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

  Widget _buildSocialSignInSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(76), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -1))],
      ),
      child: Column(
        children: [
          const Text('Or Sign-In with'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton('assets/google.png', () {}),
              const SizedBox(width: 15),
              _buildSocialButton('assets/microsoft.png', () {}),
              const SizedBox(width: 15),
              _buildSocialButton('assets/apple.png', () {}),
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
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
        child: Image.asset(
          imagePath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            developer.log('Error loading image: $imagePath, Error: $error', name: 'SuccessPage');
            return Icon(
              imagePath.contains('google') ? Icons.g_mobiledata : imagePath.contains('microsoft') ? Icons.window : Icons.apple,
              size: 24,
            );
          },
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    final secondaryPaint = Paint()..color = Colors.blue.withAlpha(51)..style = PaintingStyle.fill;
    final curvePath1 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.1, size.width, size.height * 0.2)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.4, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(curvePath1, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}