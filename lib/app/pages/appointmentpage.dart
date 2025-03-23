import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/DoctorListPage.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:logging/logging.dart'; // Import logging for consistency
import 'package:share_plus/share_plus.dart'; // For sharing functionality

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> with SingleTickerProviderStateMixin {
  final _logger = Logger('AppointmentHistoryPage');
  final TextEditingController _searchController = TextEditingController();
  bool _isSortedAscending = true;
  bool _isTimelineView = false;
  String _selectedCategory = 'All';
  late AnimationController _fabController;

  // Sample appointment data with category
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      title: 'Dentist Checkup',
      dateTime: DateTime.now().subtract(Duration(days: 2)),
      location: 'Dental Clinic',
      description: 'Regular dental checkup and cleaning',
      category: 'Medical',
    ),
    Appointment(
      id: '2',
      title: 'Team Meeting',
      dateTime: DateTime.now().add(Duration(days: 1)),
      location: 'Office Room 3',
      description: 'Weekly team sync-up meeting',
      category: 'Work',
    ),
    Appointment(
      id: '3',
      title: 'Doctor Consultation',
      dateTime: DateTime.now().add(Duration(days: 3)),
      location: 'Medical Center',
      description: 'Follow-up consultation with Dr. Smith',
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
    _filteredAppointments.sort((a, b) => _isSortedAscending
        ? a.dateTime.compareTo(b.dateTime)
        : b.dateTime.compareTo(a.dateTime));
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pastAppointments = _filteredAppointments
        .where((appointment) => appointment.dateTime.isBefore(now))
        .toList();
    final futureAppointments = _filteredAppointments
        .where((appointment) => appointment.dateTime.isAfter(now))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.1), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: Image.asset(
            'assets/back.png',
            width: 45,
            height: 50,
            color: Colors.black,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.arrow_back, color: Colors.black, size: 30),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSortedAscending ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.black),
            onPressed: _toggleSortOrder,
            tooltip: 'Sort by Date',
          ),
          IconButton(
            icon: Icon(_isTimelineView ? Icons.list : Icons.timeline, color: Colors.black),
            onPressed: _toggleView,
            tooltip: 'Toggle View',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search appointments...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Category Filter
              DropdownButton<String>(
                value: _selectedCategory,
                items: ['All', 'Medical', 'Work'].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _filterAppointments();
                  });
                },
                underline: SizedBox(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),
              // Future Appointments
              Text(
                'Upcoming Appointments',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 10),
              _isTimelineView
                  ? _buildTimelineView(futureAppointments, true)
                  : _buildAppointmentList(futureAppointments, true),
              SizedBox(height: 20),
              // Past Appointments
              Text(
                'Past Appointments',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 10),
              _isTimelineView
                  ? _buildTimelineView(pastAppointments, false)
                  : _buildAppointmentList(pastAppointments, false),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
        ),
        child: FloatingActionButton(
          onPressed: () async {
            _fabController.forward().then((_) => _fabController.reverse());
            _logger.info('Navigating to DoctorsListPage from FAB');

            // Navigate to DoctorsListPage and wait for the result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorsListPage()),
            );

            // If an appointment was returned, add it to the list
            if (result != null && result is Appointment) {
              setState(() {
                _appointments.add(result);
                _filterAppointments();
              });
            }
          },
          child: Icon(Icons.add),
          tooltip: 'Book New Appointment',
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, bool isFuture) {
    if (appointments.isEmpty) {
      return Text(
        'No ${isFuture ? 'upcoming' : 'past'} appointments',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return GestureDetector(
          onTap: () => _showAppointmentDetails(appointment),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                radius: 8,
                backgroundColor: isFuture ? Colors.green : Colors.grey,
              ),
              title: Text(
                appointment.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(appointment.location),
                ],
              ),
              trailing: isFuture
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: TextButton(
                        onPressed: () => _cancelAppointment(appointment),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView(List<Appointment> appointments, bool isFuture) {
    if (appointments.isEmpty) {
      return Text(
        'No ${isFuture ? 'upcoming' : 'past'} appointments',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0,
          isLast: index == appointments.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: isFuture ? Colors.green : Colors.grey,
            padding: EdgeInsets.only(right: 10),
          ),
          endChild: GestureDetector(
            onTap: () => _showAppointmentDetails(appointment),
            child: Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 5),
                    Text(
                      DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(appointment.location),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(appointment.title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime)}'),
            SizedBox(height: 8),
            Text('Location: ${appointment.location}'),
            SizedBox(height: 8),
            Text('Category: ${appointment.category}'),
            SizedBox(height: 8),
            Text('Description: ${appointment.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Share.share(
                'Appointment: ${appointment.title}\nDate: ${DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime)}\nLocation: ${appointment.location}\nDescription: ${appointment.description}',
              );
            },
            child: Text('Share', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    setState(() {
      _appointments.remove(appointment);
      _filterAppointments();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment cancelled')),
    );
    _logger.info('Cancelled appointment: ${appointment.title}');
  }
}

// Appointment Model (already defined in your code)
class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final String description;
  final String category;

  Appointment({
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
    required this.isFirst,
    required this.isLast,
    required this.indicatorStyle,
    required this.endChild,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            if (!isFirst) SizedBox(height: 10),
            Container(
              width: indicatorStyle.width,
              height: indicatorStyle.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: indicatorStyle.color,
              ),
            ),
            if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey[300])),
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