import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart';
import 'package:flutter_project/app/pages/medicine_page.dart';
import 'package:flutter_project/app/pages/profile-page.dart';
import 'package:flutter_project/app/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicinesListPage extends StatefulWidget {
  const MedicinesListPage({super.key});

  @override
  State<MedicinesListPage> createState() => _MedicinesListPageState();
}

class _MedicinesListPageState extends State<MedicinesListPage> with SingleTickerProviderStateMixin {
  String _selectedRoutine = 'Morning';
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _filteredMedicines = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicines() async {
    final mockData = [
      {'name': 'Cyra D', 'dosage': '40', 'instruction': 'Eat Before', 'routine': 'Morning'},
      {'name': 'Dolo', 'dosage': '650 mg', 'instruction': 'Eat After Breakfast', 'routine': 'Morning'},
      {'name': 'Fol', 'dosage': '5mg', 'instruction': 'Eat After Breakfast', 'routine': 'Morning'},
      {'name': 'Aspirin', 'dosage': '100mg', 'instruction': 'Eat After Lunch', 'routine': 'Afternoon'},
      {'name': 'Paracetamol', 'dosage': '500mg', 'instruction': 'Eat Before Sleep', 'routine': 'Night'},
    ];

    setState(() {
      _medicines = mockData;
      _filteredMedicines = mockData.where((medicine) => medicine['routine'] == _selectedRoutine).toList();
    });
  }

  void _filterMedicines(String routine) {
    setState(() {
      _selectedRoutine = routine;
      _filteredMedicines = _medicines.where((medicine) => medicine['routine'] == routine).toList();
    });
  }

  void _filterBySearch(String query) {
    setState(() {
      _filteredMedicines = _medicines
          .where((medicine) =>
              medicine['name'].toLowerCase().contains(query.toLowerCase()) &&
              medicine['routine'] == _selectedRoutine)
          .toList();
    });
  }
Future<void> navigateToHomePage(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username') ?? 'User';
  final fullName = prefs.getString('fullName') ?? 'User'; // Retrieve fullName
  final profileImage = prefs.getString('profileImage');

  Navigator.pushNamed(
    context,
    '/home',
    arguments: {
      'username': username,
      'fullName': fullName, // Pass fullName
      'profileImage': profileImage,
    },
  );
}
  void _navigateToMedicineDetails(String medicineName) {
    Navigator.pushNamed(context, '/medicines-list', arguments: medicineName);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _controller.forward().then((_) => _controller.reverse());
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage(username: 'Email', fullName: 'User',)));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchPage()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate heights and padding
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final searchBarHeight = screenHeight * 0.08; // Fixed height for search bar
    final mmToPx = MediaQuery.of(context).devicePixelRatio * 3.78 / 2.54; // 1mm in pixels
    final searchTopPadding = screenHeight * 0.02; // Space between AppBar and search bar

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset('assets/back.png', width: screenWidth * 0.05, height: screenWidth * 0.05, errorBuilder: (_, __, ___) => Icon(Icons.arrow_back, size: screenWidth * 0.05)),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Medicines List',
                style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ),
            DropdownButton<String>(
              value: _selectedRoutine,
              items: <String>['Morning', 'Afternoon', 'Night'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) _filterMedicines(newValue);
              },
              icon: Icon(Icons.arrow_drop_down, size: screenWidth * 0.06, color: Colors.black),
              underline: Container(),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
          ],
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.04, appBarHeight, screenWidth * 0.04, 12 + 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: searchTopPadding),
                child: SizedBox(
                  height: searchBarHeight,
                  width: screenWidth * 0.9,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search medicines...',
                      hintStyle: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
                      prefixIcon: Icon(Icons.search, size: screenWidth * 0.05, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(searchBarHeight / 2),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(searchBarHeight / 2),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(searchBarHeight / 2),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _filterBySearch,
                  ),
                ),
              ),
              SizedBox(height: 2 * mmToPx), // 2mm gap between search bar and medicine cards
              Column(
                children: _filteredMedicines.map((medicine) {
                  return GestureDetector(
                    onTap: () => _navigateToMedicineDetails(medicine['name']),
                    child: Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(color: Colors.black.withOpacity(0.2), width: 1), // Same stroke as search bar
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: screenWidth * 0.012,
                            spreadRadius: screenWidth * 0.005,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(screenWidth * 0.04),
                        leading: Container(
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                          child: Image.asset(
                            'assets/medicine.png',
                            width: screenWidth * 0.08,
                            height: screenWidth * 0.08,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.medical_services,
                              size: screenWidth * 0.08,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(
                          '${medicine['name']} - ${medicine['dosage']}',
                          style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.005),
                          child: Text(
                            medicine['instruction'],
                            style: TextStyle(fontSize: screenWidth * 0.035),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Text(
                          medicine['routine'],
                          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(76), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _buildNavItem(Icons.person, 0, 'Profile'),
            _buildNavItem(Icons.science_outlined, 1, 'Tests'),
            _buildNavItem(Icons.home, 2, 'Home'),
            _buildNavItem(Icons.search, 3, 'Search'),
            _buildNavItem(Icons.person_outline, 4, 'Account'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index, String label) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _selectedIndex == index ? _animation.value : 0),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _selectedIndex == index ? Colors.white : Colors.grey),
            ),
          );
        },
      ),
      label: label,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const MedicinesListPage(),
    routes: {
      '/profile': (context) => const ProfilePage(),
      '/home': (context) => const HomePage(username: 'Email', fullName: 'User',),
      '/search': (context) => const SearchPage(),
      '/medicines-list': (context) {
        final String? medicineName = ModalRoute.of(context)?.settings.arguments as String?;
        return MedicinePage(medicineName: medicineName);
      },
    },
  ));
}