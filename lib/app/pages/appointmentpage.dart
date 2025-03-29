import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/DoctorListPage.dart';
import 'package:flutter_project/app/pages/video_page.dart'; // Video call page import
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> 
    with SingleTickerProviderStateMixin {
  final _logger = Logger('AppointmentHistoryPage');
  final TextEditingController _searchController = TextEditingController();
  bool _isSortedAscending = true;
  bool _isTimelineView = false;
  String _selectedCategory = 'All';
  late AnimationController _fabController;

  // Sample appointment data
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
        final matchesCategory = _selectedCategory == 'All' || 
            appointment.category == _selectedCategory;
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

  void _startVideoCall(String doctorName) {
    final callId = '${_userId}_${DateTime.now().millisecondsSinceEpoch}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConsultPage(
          doctorName: doctorName,
          callId: callId,
        ),
      ),
    );
  }

  String _extractDoctorName(String title) {
    // Extract doctor name from appointment title
    final regex = RegExp(r'(Dr\.|Dr\s|with\s)([\w\s]+)');
    final match = regex.firstMatch(title);
    return match?.group(2)?.trim() ?? 'Doctor';
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
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSortedAscending ? Icons.arrow_upward : Icons.arrow_downward, 
              color: Colors.black),
            onPressed: _toggleSortOrder,
            tooltip: 'Sort by Date',
          ),
          IconButton(
            icon: Icon(
              _isTimelineView ? Icons.list : Icons.timeline, 
              color: Colors.black),
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
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search appointments...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Category Filter
              DropdownButton<String>(
                value: _selectedCategory,
                items: ['All', 'Medical', 'Work'].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _filterAppointments();
                  });
                },
                underline: const SizedBox(),
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 20),
              // Future Appointments
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black),
              ),
              const SizedBox(height: 10),
              _isTimelineView
                  ? _buildTimelineView(futureAppointments, true)
                  : _buildAppointmentList(futureAppointments, true),
              const SizedBox(height: 20),
              // Past Appointments
              const Text(
                'Past Appointments',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black),
              ),
              const SizedBox(height: 10),
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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoctorsListPage()),
            );
            if (result != null && result is Appointment) {
              setState(() {
                _appointments.add(result);
                _filterAppointments();
              });
            }
          },
          tooltip: 'Book New Appointment',
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, bool isFuture) {
    if (appointments.isEmpty) {
      return Text(
        'No ${isFuture ? 'upcoming' : 'past'} appointments',
        style: const TextStyle(color: Colors.grey),
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
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                radius: 8,
                backgroundColor: isFuture ? Colors.green : Colors.grey,
              ),
              title: Text(
                appointment.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (appointment.category == 'Medical')
                          IconButton(
                            icon: const Icon(Icons.video_call, color: Colors.green),
                            onPressed: () => _startVideoCall(_extractDoctorName(appointment.title)),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                          child: TextButton(
                            onPressed: () => _cancelAppointment(appointment),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
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
        style: const TextStyle(color: Colors.grey),
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
            width: 20,
            color: isFuture ? Colors.green : Colors.grey,
            padding: const EdgeInsets.only(right: 10),
          ),
          endChild: GestureDetector(
            onTap: () => _showAppointmentDetails(appointment),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 18),
                          ),
                        ),
                        if (isFuture && appointment.category == 'Medical')
                          IconButton(
                            icon: const Icon(
                              Icons.video_call, 
                              color: Colors.green),
                            onPressed: () => _startVideoCall(
                              _extractDoctorName(appointment.title)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
        title: Text(
          appointment.title, 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime)}'),
            const SizedBox(height: 8),
            Text('Location: ${appointment.location}'),
            const SizedBox(height: 8),
            Text('Category: ${appointment.category}'),
            const SizedBox(height: 8),
            Text('Description: ${appointment.description}'),
          ],
        ),
        actions: [
          if (appointment.category == 'Medical')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startVideoCall(_extractDoctorName(appointment.title));
              },
              child: const Text('Video Call', style: TextStyle(color: Colors.green)),
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
            child: const Text('Share', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.black)),
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
      const SnackBar(content: Text('Appointment cancelled')),
    );
    _logger.info('Cancelled appointment: ${appointment.title}');
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
            if (!isLast) Expanded(
              child: Container(width: 2, color: Colors.grey[300])),
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