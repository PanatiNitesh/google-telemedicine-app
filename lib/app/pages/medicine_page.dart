import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/HomePage.dart';
import 'package:flutter_project/app/pages/profile-page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:logging/logging.dart';

class MedicinePage extends StatefulWidget {
  final String? medicineName;

  const MedicinePage({super.key, this.medicineName});

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
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      final mockData = [
        {'name': 'Paracetamol', 'dosage': '500mg', 'time': '08:00 AM'},
        {'name': 'Ibuprofen', 'dosage': '200mg', 'time': '12:00 PM'},
        {'name': 'Aspirin', 'dosage': '100mg', 'time': '06:00 PM'},
      ];

      List<dynamic> filteredMedicines;
      if (widget.medicineName != null) {
        filteredMedicines = mockData.where((medicine) => medicine['name'] == widget.medicineName).toList();
        if (filteredMedicines.isEmpty) {
          // If no match, use full mock data for calendar view
          filteredMedicines = mockData;
        }
      } else {
        filteredMedicines = mockData;
      }

      setState(() {
        _medicines = filteredMedicines;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load medicines. Please try again later.";
      });
      _logger.severe('Error fetching medicines: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
    _controller.forward().then((_) => _controller.reverse());

    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
      case 1:
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomePage(username: 'User')));
        break;
      case 3:
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
    }
  }

  // Simulate medicine dates (for demo, assume all medicines are daily)
  List<DateTime> _getMedicineDates() {
    // For simplicity, mark today and tomorrow as medicine days
    return [
      DateTime.now(),
      DateTime.now().add(const Duration(days: 1)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final medicineDates = _getMedicineDates();

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
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
          widget.medicineName != null
              ? 'Medicine: ${widget.medicineName}'
              : 'Medicines List',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Always show calendar unless in detailed view with a match
            if (widget.medicineName == null || _medicines.length == 3) ...[
              SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  "Select a Date",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
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
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        cellMargin: EdgeInsets.all(screenWidth * 0.005),
                        defaultTextStyle: TextStyle(fontSize: screenWidth * 0.035),
                        weekendTextStyle: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.red,
                        ),
                        outsideTextStyle: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey,
                        ),
                        markersMaxCount: 1,
                        markerDecoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          size: screenWidth * 0.06,
                          color: Colors.black,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          size: screenWidth * 0.06,
                          color: Colors.black,
                        ),
                      ),
                      eventLoader: (day) {
                        return medicineDates.any((date) => isSameDay(date, day)) ? [true] : [];
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  "Your Medicine List",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
            _isLoading
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : _errorMessage.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                        child: Center(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: screenWidth * 0.04,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Column(
                        children: _medicines.map((medicine) {
                          if (widget.medicineName != null && _medicines.length < 3) {
                            // Detailed view mode when there's a match
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.02),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/medicine.png',
                                            width: screenWidth * 0.1,
                                            height: screenWidth * 0.1,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(
                                              Icons.medical_services,
                                              size: screenWidth * 0.1,
                                              color: Colors.red,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.04),
                                          Text(
                                            medicine['name'],
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.06,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Text(
                                        'Dosage: ${medicine['dosage']}',
                                        style: TextStyle(fontSize: screenWidth * 0.045),
                                      ),
                                      Text(
                                        'Time: ${medicine['time']}',
                                        style: TextStyle(fontSize: screenWidth * 0.045),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // List view mode
                            return MedicineTile(
                              medicineName: medicine['name'],
                              dosage: medicine['dosage'],
                              time: medicine['time'],
                            );
                          }
                        }).toList(),
                      ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(screenWidth),
    );
  }

  Widget _buildBottomNavBar(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final navBarHeight =
        screenHeight * (MediaQuery.of(context).orientation == Orientation.portrait ? 0.12 : 0.18);

    return Container(
      height: navBarHeight,
      margin: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76),
            spreadRadius: screenWidth * 0.002,
            blurRadius: screenWidth * 0.025,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.person, 0, 'Profile', screenWidth),
            _buildNavItem(Icons.science_outlined, 1, 'Tests', screenWidth),
            _buildNavItem(Icons.home, 2, 'Home', screenWidth),
            _buildNavItem(Icons.search, 3, 'Search', screenWidth),
            _buildNavItem(Icons.person_outline, 4, 'Account', screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label, double screenWidth) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _selectedIndex == index ? _animation.value : 0),
            child: CircleAvatar(
              radius: screenWidth * 0.06,
              backgroundColor: _selectedIndex == index ? Colors.blue : Colors.transparent,
              child: Icon(
                icon,
                size: screenWidth * 0.06,
                color: _selectedIndex == index ? Colors.white : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MedicineTile extends StatelessWidget {
  final String medicineName;
  final String dosage;
  final String time;

  const MedicineTile({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02,
        horizontal: screenWidth * 0.03,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: ListTile(
        leading: Icon(FontAwesomeIcons.pills, color: Colors.green),
        title: Text(
          medicineName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dosage,
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            Text(
              'Time: $time',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.check_circle, color: Colors.blue),
      ),
    );
  }
}