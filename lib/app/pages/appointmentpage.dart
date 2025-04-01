import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'video_page.dart';

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSortedAscending = true;
  bool _isTimelineView = false;
  String _selectedCategory = 'All';
  late AnimationController _fabController;

  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      title: 'Dentist Checkup with Dr. Smith',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Dental Clinic',
      description: 'Regular dental checkup and cleaning',
      category: 'Medical',
    ),
    Appointment(
      id: '2',
      title: 'Team Meeting',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      location: 'Office Room 3',
      description: 'Weekly team sync-up meeting',
      category: 'Work',
    ),
    Appointment(
      id: '3',
      title: 'Consultation with Dr. Johnson',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      location: 'Medical Center',
      description: 'Follow-up consultation',
      category: 'Medical',
    ),
  ];

  List<Appointment> _filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    _filteredAppointments = List.from(_appointments);
    _searchController.addListener(_filterAppointments);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  String get _userId => 'patient_${DateTime.now().millisecondsSinceEpoch}';

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAppointments = _appointments.where((appointment) {
        final matchesSearch = appointment.title.toLowerCase().contains(query) ||
            appointment.location.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'All' || appointment.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
      _sortAppointments();
    });
  }

  void _sortAppointments() {
    _filteredAppointments.sort((a, b) =>
        _isSortedAscending ? a.dateTime.compareTo(b.dateTime) : b.dateTime.compareTo(a.dateTime));
  }

  void _toggleSortOrder() {
    setState(() {
      _isSortedAscending = !_isSortedAscending;
      _sortAppointments();
    });
  }

  void _toggleView() {
    setState(() {
      _isTimelineView = !_isTimelineView;
    });
  }

  void _startVideoCall(String doctorName) {
    final callId = '${_userId}_${DateTime.now().millisecondsSinceEpoch}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConsultPage(
          doctorName: doctorName,
          callId: callId,
          userRole: 'patient', // Patient initiates the call
        ),
      ),
    );
  }

  String _extractDoctorName(String title) {
    final regex = RegExp(r'(Dr\.|Dr\s|with\s)([\w\s]+)');
    final match = regex.firstMatch(title);
    return match?.group(2)?.trim() ?? 'Doctor';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final now = DateTime.now();
    final pastAppointments =
        _filteredAppointments.where((appointment) => appointment.dateTime.isBefore(now)).toList();
    final futureAppointments =
        _filteredAppointments.where((appointment) => appointment.dateTime.isAfter(now)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: screenWidth * 0.08),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSortedAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.black,
              size: screenWidth * 0.06,
            ),
            onPressed: _toggleSortOrder,
            tooltip: 'Sort by Date',
          ),
          IconButton(
            icon: Icon(
              _isTimelineView ? Icons.list : Icons.timeline,
              color: Colors.black,
              size: screenWidth * 0.06,
            ),
            onPressed: _toggleView,
            tooltip: 'Toggle View',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search appointments...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: ['All', 'Medical', 'Work'].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _filterAppointments();
                      });
                    },
                    underline: const SizedBox(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    dropdownColor: Colors.white,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Upcoming Appointments',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _isTimelineView
                      ? _buildTimelineView(futureAppointments, true, screenWidth, screenHeight)
                      : _buildAppointmentList(futureAppointments, true, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Past Appointments',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _isTimelineView
                      ? _buildTimelineView(pastAppointments, false, screenWidth, screenHeight)
                      : _buildAppointmentList(pastAppointments, false, screenWidth, screenHeight),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
        ),
        child: FloatingActionButton(
          onPressed: () async {
            _fabController.forward().then((_) => _fabController.reverse());
            final result = await Navigator.pushNamed(context, '/doctorsList');
            if (result != null && result is Appointment) {
              setState(() {
                _appointments.add(result);
                _filterAppointments();
              });
            }
          },
          tooltip: 'Book New Appointment',
          backgroundColor: Colors.blue,
          child: Icon(Icons.add, size: screenWidth * 0.06),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(
      List<Appointment> appointments, bool isFuture, double screenWidth, double screenHeight) {
    if (appointments.isEmpty) {
      return Text(
        'No ${isFuture ? 'upcoming' : 'past'} appointments',
        style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return GestureDetector(
          onTap: () => _showAppointmentDetails(appointment),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.02,
                    backgroundColor: isFuture ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        Text(
                          appointment.location,
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                      ],
                    ),
                  ),
                  if (isFuture && appointment.category == 'Medical')
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.video_call,
                              color: Colors.green,
                              size: screenWidth * 0.06,
                            ),
                            onPressed: () => _startVideoCall(_extractDoctorName(appointment.title)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView(
      List<Appointment> appointments, bool isFuture, double screenWidth, double screenHeight) {
    if (appointments.isEmpty) {
      return Text(
        'No ${isFuture ? 'upcoming' : 'past'} appointments',
        style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0,
          isLast: index == appointments.length - 1,
          indicatorStyle: IndicatorStyle(
            width: screenWidth * 0.05,
            color: isFuture ? Colors.green : Colors.grey,
            padding: EdgeInsets.only(right: screenWidth * 0.03),
          ),
          endChild: GestureDetector(
            onTap: () => _showAppointmentDetails(appointment),
            child: Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                          Text(
                            appointment.location,
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                        ],
                      ),
                    ),
                    if (isFuture && appointment.category == 'Medical')
                      IconButton(
                        icon: Icon(
                          Icons.video_call,
                          color: Colors.green,
                          size: screenWidth * 0.06,
                        ),
                        onPressed: () => _startVideoCall(_extractDoctorName(appointment.title)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          appointment.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime)}',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'Location: ${appointment.location}',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'Category: ${appointment.category}',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'Description: ${appointment.description}',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
          ],
        ),
        actions: [
          if (appointment.category == 'Medical')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startVideoCall(_extractDoctorName(appointment.title));
              },
              child: Text(
                'Video Call',
                style: TextStyle(color: Colors.green, fontSize: screenWidth * 0.04),
              ),
            ),
          TextButton(
            onPressed: () {
              Share.share(
                'Appointment: ${appointment.title}\n'
                'Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime)}\n'
                'Location: ${appointment.location}\n'
                'Description: ${appointment.description}',
              );
            },
            child: Text(
              'Share',
              style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.04),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.04),
            ),
          ),
        ],
      ),
    );
  }
}

class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final String description;
  final String category;

  const Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.category,
  });
}

class TimelineTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final IndicatorStyle indicatorStyle;
  final Widget endChild;
  final TimelineAlign alignment;

  const TimelineTile({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.indicatorStyle,
    required this.endChild,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst) const SizedBox(height: 10),
            Container(
              width: indicatorStyle.width,
              height: indicatorStyle.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: indicatorStyle.color,
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey[300],
                ),
              ),
          ],
        ),
        SizedBox(width: indicatorStyle.padding.right),
        Expanded(child: endChild),
      ],
    );
  }
}

class IndicatorStyle {
  final double width;
  final Color color;
  final EdgeInsets padding;

  const IndicatorStyle({
    required this.width,
    required this.color,
    this.padding = EdgeInsets.zero,
  });
}

enum TimelineAlign { start }