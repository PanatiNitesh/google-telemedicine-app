import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/back.png', 
            width: 35, 
            height: 35,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Meet Our Team ',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.075,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: 'DOCKERIZE',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'We are a team of three passionate individuals participating in a Solution Challenge hackathon to build innovative healthcare solutions.',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              
              _buildTeamMemberCard(
                context,
                name: 'Ravindra S',
                roles: [
                  'Lead Developer',
                  'Backend Developer',
                  'UI/UX Developer'
                ],
                description: 'Ravindra S is an expert in Flutter and backend development, leading the technical implementation of our telemedicine app.',
                image: 'assets/ravindra.png',
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildTeamMemberCard(
                context,
                name: 'P Nitesh',
                roles: [
                  'UI/UX Designer',
                  'Frontend Developer',
                  'Backend Developer'
                ],
                description: 'P Nitesh crafts intuitive and beautiful user interfaces, ensuring a seamless experience for our users.',
                image: 'assets/nitesh.png',
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildTeamMemberCard(
                context,
                name: 'Pooja CG',
                roles: [
                  'Content Creator',
                  'Backend Developer',
                  'Project Manager'
                ],
                description: 'Pooja coordinates the team, manages timelines, and ensures our project aligns with the hackathon goals.',
                image: 'assets/pooja.jpg',
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(
    BuildContext context, {
    required String name,
    required List<String> roles,
    required String description,
    required String image,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              width: screenWidth * 0.25,
              height: screenWidth * 0.25,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withAlpha(100), 
                      Colors.blue.withAlpha(200)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: screenWidth * 0.1,
                    color: Colors.blue.withAlpha(500),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                AnimatedRoleText(
                  roles: roles,
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedRoleText extends StatefulWidget {
  final List<String> roles;
  final double screenWidth;

  const AnimatedRoleText({
    super.key,
    required this.roles,
    required this.screenWidth,
  });

  @override
  State<AnimatedRoleText> createState() => _AnimatedRoleTextState();
}

class _AnimatedRoleTextState extends State<AnimatedRoleText> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentRoleIndex = 0;
  late String _currentRole;
  List<double> _letterOpacities = [];

  @override
  void initState() {
    super.initState();
    
    _currentRole = widget.roles[_currentRoleIndex];
    _letterOpacities = List.generate(_currentRole.length, (index) => 1.0);

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        _updateLetterOpacities(_controller.value);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _changeRole();
      }
    });

    _controller.forward();
  }

  void _updateLetterOpacities(double animationValue) {
    if (animationValue <= 0.5) {
      int lettersToFadeOut = (_currentRole.length * (animationValue * 2)).ceil();
      _letterOpacities = List.generate(
        _currentRole.length, 
        (index) => index < lettersToFadeOut ? 1.0 - (animationValue * 2) : 1.0
      );
    } else {
      _letterOpacities = List.generate(_currentRole.length, (index) => 0.0);
    }
  }

  void _changeRole() {
    setState(() {
      _currentRoleIndex = (_currentRoleIndex + 1) % widget.roles.length;
      _currentRole = widget.roles[_currentRoleIndex];
      
      _letterOpacities = List.generate(_currentRole.length, (index) => 1.0);
      
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: List.generate(
          _currentRole.length, 
          (index) => TextSpan(
            text: _currentRole[index],
            style: GoogleFonts.poppins(
              fontSize: widget.screenWidth * 0.035,
              color: Colors.blue.shade700.withAlpha(
                (_letterOpacities[index] * 255).toInt()
              ),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}