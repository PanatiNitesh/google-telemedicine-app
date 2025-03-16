import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/app/pages/DoctorListPage.dart';
import 'package:flutter_project/app/pages/HomePage.dart' as home_page;
import 'package:flutter_project/app/pages/medicines_list_page.dart';
import 'package:flutter_project/app/pages/profile-page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_project/app/pages/login.dart';
import 'package:flutter_project/app/pages/register.dart';
import 'package:flutter_project/app/pages/chat_bot.dart' as chat_bot;
import 'package:flutter_project/app/pages/search_page.dart';
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:flutter_project/app/pages/medicine_page.dart';
import 'package:flutter_project/app/pages/labtests.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeDotEnv() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await dotenv.load(fileName: "assets/.env");
      print("Loaded .env successfully");
    } catch (e) {
      print("Error loading .env: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeDotEnv(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TelemedicineApp();
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F6AF3),
                        strokeWidth: 8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Loading...",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4F6AF3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class TelemedicineApp extends StatelessWidget {
  const TelemedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4F6AF3),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF4F6AF3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4F6AF3),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F6AF3),
          primary: const Color(0xFF4F6AF3),
          secondary: const Color(0xFFDCE1FE),
          tertiary: const Color(0xFF6C63FF),
        ),
      ),
      home: const MainPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] as String? ?? 'User';
          return home_page.HomePage(username: username);
        },
        '/profile': (context) => const ProfilePage(),
        '/ai_diagnose': (context) => const chat_bot.ChatScreen(),
        '/search': (context) => const SearchPage(),
        '/doctors_list': (context) => const DoctorsListPage(),
        '/test_results': (context) => const TestResults(),
        '/medicines': (context) => const MedicinesListPage(),
        '/lab_tests': (context) => const LabTestsApp(),
        '/medicines-list': (context) {
          final String? medicineName = ModalRoute.of(context)?.settings.arguments as String?;
          return MedicinePage(medicineName: medicineName);
        },
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, 
                      size: 80, 
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Page Not Found',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route not found: ${settings.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/home'),
                    child: const Text('Go to Home'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _features = [
    {
      'title': 'Smart Healthcare\nfor Everyone',
      'subtitle': 'Access quality care anytime,\nanywhere',
      'image': 'assets/doctor.png',
    },
    {
      'title': 'AI-Powered\nDiagnosis',
      'subtitle': 'Get preliminary assessments\nwithin seconds',
      'image': 'assets/ai_doctor.png',
    },
    {
      'title': 'Connect with\nSpecialists',
      'subtitle': 'Video consultations with\nexperienced doctors',
      'image': 'assets/specialist.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Auto-scroll the PageView
    Future.delayed(const Duration(seconds: 3), () {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_currentPage < _features.length - 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFF0F3FF), Colors.white],
              ),
            ),
          ),
          
          // Top clipper shapes
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CustomClip(),
              child: Container(
                height: screenHeight * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4F6AF3), Color(0xFF6C63FF)],
                  ),
                ),
              ),
            ),
          ),
          
          // Secondary clipper
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: SecondaryClip(),
              child: Container(
                height: screenHeight * 0.4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE1FE).withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Glass effect card at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.22,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),
          
          // Login button with glass effect
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F6AF3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Feature carousel with PageView
          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.15,
            bottom: screenHeight * 0.22,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _features.length,
              itemBuilder: (context, index) {
                return _buildFeatureItem(
                  context, 
                  _features[index]['title'] ?? '',
                  _features[index]['subtitle'] ?? '',
                  _features[index]['image'] ?? '',
                  screenWidth,
                  screenHeight
                );
              },
            ),
          ),
          
          // Bottom controls (dots and buttons)
          Positioned(
            bottom: screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_features.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index 
                              ? const Color(0xFF4F6AF3) 
                              : const Color(0xFF4F6AF3).withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Get Started Button
                      Expanded(
                        child: AnimatedGetStartedButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Learn More Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Learn more feature coming soon!'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: const Color(0xFF4F6AF3),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4F6AF3),
                            elevation: 0,
                            side: const BorderSide(
                              color: Color(0xFF4F6AF3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            "Learn More",
                            style: GoogleFonts.poppins(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String subtitle, String image, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feature title with animated text
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Colors.black87,
              ),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.01),
          
          // Feature subtitle with animated text
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.04,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Feature image with animated fade
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Hero(
                tag: 'feature_image_$image',
                child: Image.asset(
                  image,
                  height: screenHeight * 0.35,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: screenHeight * 0.35,
                    width: screenWidth * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Image not found",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Custom Clipper for the blue background
class CustomClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    
    // Create a more interesting curve
    path.quadraticBezierTo(
      size.width * 0.25, 
      size.height - 50, 
      size.width * 0.5, 
      size.height - 70
    );
    
    path.quadraticBezierTo(
      size.width * 0.75, 
      size.height - 90, 
      size.width, 
      size.height * 0.3
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Enhanced Custom Clipper for the secondary shape
class SecondaryClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.4, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.3);
    
    // Create a more organic shape
    path.cubicTo(
      size.width * 0.8, size.height * 0.2,
      size.width * 0.6, size.height * 0.1,
      size.width * 0.5, size.height * 0.35
    );
    
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.5,
      size.width * 0.3, size.height * 0.38
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Animated Get Started Button with improved effects
class AnimatedGetStartedButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedGetStartedButton({
    required this.onPressed,
    super.key,
  });

  @override
  _AnimatedGetStartedButtonState createState() => _AnimatedGetStartedButtonState();
}

class _AnimatedGetStartedButtonState extends State<AnimatedGetStartedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F6AF3).withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 20,
                spreadRadius: _glowAnimation.value * 5,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F6AF3),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Get Started",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}