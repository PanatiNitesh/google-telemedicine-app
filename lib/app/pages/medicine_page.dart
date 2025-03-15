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

class _MedicinePageState extends State<MedicinePage> with SingleTickerProviderStateMixin {
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
      await Future.delayed(const Duration(seconds: 1));
      final mockData = [
        {'name': 'Paracetamol', 'dosage': '500mg', 'time': '08:00 AM'},
        {'name': 'Ibuprofen', 'dosage': '200mg', 'time': '12:00 PM'},
        {'name': 'Aspirin', 'dosage': '100mg', 'time': '06:00 PM'},
      ];
      List<dynamic> filteredMedicines = widget.medicineName != null
          ? mockData.where((medicine) => medicine['name'] == widget.medicineName).toList().isEmpty
              ? mockData
              : mockData.where((medicine) => medicine['name'] == widget.medicineName).toList()
          : mockData;
      setState(() => _medicines = filteredMedicines);
    } catch (e) {
      setState(() => _errorMessage = "Failed to load medicines. Please try again later.");
      _logger.severe('Error fetching medicines: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _controller.forward().then((_) => _controller.reverse());
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
      case 1:
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage(username: 'User')));
        break;
      case 3:
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  List<DateTime> _getMedicineDates() {
    return [DateTime.now(), DateTime.now().add(const Duration(days: 1))];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final medicineDates = _getMedicineDates();

    // Calculate the AppBar height dynamically
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    // Convert 1mm to logical pixels (assuming 1mm ≈ 3.78 pixels at 96 DPI, adjust based on device DPI)
    final mmToPx = MediaQuery.of(context).devicePixelRatio * 3.78 / 2.54; // 1mm in pixels
    final topPadding = appBarHeight + mmToPx; // AppBar height + 1mm gap

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
            child: Image.asset('assets/back.png', width: screenWidth * 0.05, height: screenWidth * 0.05, errorBuilder: (_, __, ___) => Icon(Icons.arrow_back, size: screenWidth * 0.05)),
          ),
        ),
        title: Text(
          widget.medicineName != null ? 'Medicine: ${widget.medicineName}' : 'Medicines List',
          style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.04, topPadding, screenWidth * 0.04, 12 + 60), // Adjusted top padding with 1mm gap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.medicineName == null || _medicines.length == 3) ...[
                Text("Select a Date", textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
                SizedBox(height: screenHeight * 0.02),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) => setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      }),
                      onFormatChanged: (format) => setState(() => _calendarFormat = format),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.3), shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        cellMargin: EdgeInsets.all(screenWidth * 0.005),
                        defaultTextStyle: TextStyle(fontSize: screenWidth * 0.035),
                        weekendTextStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.red),
                        outsideTextStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
                        markersMaxCount: 1,
                        markerDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
                        weekendStyle: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                        leftChevronIcon: Icon(Icons.chevron_left, size: screenWidth * 0.06, color: Colors.black),
                        rightChevronIcon: Icon(Icons.chevron_right, size: screenWidth * 0.06, color: Colors.black),
                      ),
                      eventLoader: (day) => medicineDates.any((date) => isSameDay(date, day)) ? [true] : [],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text("Your Medicine List", textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
                SizedBox(height: screenHeight * 0.02),
              ],
              _isLoading
                  ? Padding(padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05), child: const Center(child: CircularProgressIndicator()))
                  : _errorMessage.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                          child: Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.04), textAlign: TextAlign.center)),
                        )
                      : Column(
                          children: _medicines.map((medicine) {
                            return widget.medicineName != null && _medicines.length < 3
                                ? Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.02)),
                                      child: Padding(
                                        padding: EdgeInsets.all(screenWidth * 0.04),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset('assets/medicine.png', width: screenWidth * 0.1, height: screenWidth * 0.1, errorBuilder: (_, __, ___) => Icon(Icons.medical_services, size: screenWidth * 0.1, color: Colors.red)),
                                                SizedBox(width: screenWidth * 0.04),
                                                Text(medicine['name'], style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            SizedBox(height: screenHeight * 0.02),
                                            Text('Dosage: ${medicine['dosage']}', style: TextStyle(fontSize: screenWidth * 0.045)),
                                            Text('Time: ${medicine['time']}', style: TextStyle(fontSize: screenWidth * 0.045)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : MedicineTile(medicineName: medicine['name'], dosage: medicine['dosage'], time: medicine['time']);
                          }).toList(),
                        ),
              SizedBox(height: screenHeight * 0.03),
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
              decoration: BoxDecoration(color: _selectedIndex == index ? Colors.blue : Colors.transparent, shape: BoxShape.circle),
              child: Icon(icon, color: _selectedIndex == index ? Colors.white : Colors.grey),
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
  final String time;

  const MedicineTile({super.key, required this.medicineName, required this.dosage, required this.time});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02, horizontal: screenWidth * 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.02)),
      child: ListTile(
        leading: Icon(FontAwesomeIcons.pills, color: Colors.green),
        title: Text(medicineName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dosage, style: TextStyle(fontSize: screenWidth * 0.04)),
            Text('Time: $time', style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey)),
          ],
        ),
        trailing: Icon(Icons.check_circle, color: Colors.blue),
      ),
    );
  }
}