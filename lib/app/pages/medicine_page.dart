import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_project/app/pages/HomePage.dart'; // Adjust imports as needed
import 'package:flutter_project/app/pages/ProfilePage.dart';
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:logging/logging.dart'; // For Logger

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<dynamic> _medicines = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final _logger = Logger('MedicinePage');
  int _selectedIndex = 1; // Default to Medicines (can adjust based on context)
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
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
          Uri.parse('http://your-backend-api.com/medicines?date=$_selectedDay'));
      if (response.statusCode == 200) {
        setState(() {
          _medicines = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load medicines";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward().then((_) => _controller.reverse());

    final Color themeColor;
    switch (index) {
      case 0:
        themeColor = Colors.purple;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
      case 1:
        themeColor = Colors.teal;
        break; // Already on MedicinePage, no navigation
      case 2:
        themeColor = Colors.blue;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomePage(username: 'User')));
        break;
      case 3:
        themeColor = Colors.amber;
        // Add search page navigation if available
        break;
      case 4:
        themeColor = Colors.red;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
      default:
        themeColor = Colors.blue;
    }
    _logger.info('Changed theme color to: $themeColor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 15, // Adjusts spacing so title appears closer to the back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 5), // Maintain spacing
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/back.png',
              width: 16, // Reduced size
              height: 16, // Reduced size
            ),
          ),
        ),
        title: const Text(
          'Medicines',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: false, // Aligns the title to the left, closer to the back button
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            "Select a Date",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchMedicines();
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your Medicine List",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(_errorMessage,
                            style: const TextStyle(color: Colors.red)))
                    : _medicines.isEmpty
                        ? const Center(
                            child: Text("No medicines found for this date."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _medicines.length,
                            itemBuilder: (context, index) {
                              return MedicineTile(
                                medicineName: _medicines[index]['name'],
                                dosage: _medicines[index]['dosage'],
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
              padding: const EdgeInsets.all(15), // Larger blue circle for selected items
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _selectedIndex == index ? Colors.white : Colors.grey,
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }
}

class MedicineTile extends StatelessWidget {
  final String medicineName;
  final String dosage;

  const MedicineTile({super.key, required this.medicineName, required this.dosage});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(FontAwesomeIcons.pills, color: Colors.green),
        title: Text(
          medicineName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dosage),
        trailing: const Icon(Icons.check_circle, color: Colors.blue),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: MedicinePage()));
}
