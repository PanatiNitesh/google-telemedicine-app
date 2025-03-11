import 'package:flutter/material.dart';
import 'package:flutter_project/app/pages/DoctorListPage.dart';
import 'package:flutter_project/app/pages/ProfilePage.dart';
import 'package:flutter_project/app/pages/TestResults.dart';
import 'package:flutter_project/app/pages/chat_bot.dart';
import 'package:flutter_project/app/pages/labtests.dart';
import 'package:flutter_project/app/pages/medicine_page.dart';



import 'package:logging/logging.dart'; // Add logging package

// Import the ProfilePage
 // Ensure this import points to the correct file

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create a logger instance
  final _logger = Logger('HomePage');
  int _selectedIndex = 2; // Home index
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterActive = false;

  // Sample data for doctors
  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Doctor-1',
      'specialty': 'Rheumatologist',
      'image': 'assets/doctor1.png', // Updated path
      'description': 'Experienced doctor specializing in joint and muscle conditions'
    },
    {
      'name': 'Doctor-2',
      'specialty': 'Dermatologist',
      'image': 'assets/doctor2.png', // Updated path
      'description': 'Skin specialist with 10+ years experience'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildFeatureTabs(),
              const SizedBox(height: 24),
              _buildDoctorsList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hi, ${widget.username}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _showNotificationDrawer,
            ),
            GestureDetector(
              onTap: () {
                // Navigate to ProfilePage when the profile icon is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 30,
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.black54,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51), // Fixed: Using withAlpha instead of withOpacity
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Doctors, medicines',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: _openGoogleLens,
              child: Image.asset(
                'assets/google_lens.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.camera_alt, size: 24);
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _performSearch(_searchController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTabs() {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.person,
        'color': Colors.blue,
        'title': 'Doctors',
        'onTap': () => _navigateToPage(0),
      },
      {
        'icon': Icons.medication,
        'color': Colors.blue,
        'title': 'Medicines',
        'onTap': () => _navigateToPage(1),
      },
      {
        'icon': Icons.calendar_today,
        'color': Colors.blue,
        'title': 'Appointments',
        'onTap': () => _navigateToPage(2),
      },
      {
        'icon': Icons.science,
        'color': Colors.blue,
        'title': 'Laboratories',
        'onTap': () => _navigateToPage(3),
      },
      {
        'icon': Icons.chat_bubble_outline,
        'color': Colors.blue,
        'title': 'AI assistant',
        'onTap': () => _navigateToPage(4),
      },
      {
        'icon': Icons.science_outlined,
        'color': Colors.blue,
        'title': 'Test results',
        'onTap': () => _navigateToPage(5),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: features.map((feature) {
        return _buildFeatureItem(
          icon: feature['icon'],
          color: feature['color'],
          title: feature['title'],
          onTap: feature['onTap'],
        );
      }).toList(),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Fix for overflow
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Doctor's List",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _toggleFilter,
                icon: Icon(
                  Icons.filter_list,
                  color: _isFilterActive ? Colors.blue : Colors.black,
                ),
                label: Text(
                  'Filter',
                  style: TextStyle(
                    color: _isFilterActive ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return _buildDoctorCard(doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8), // Reduce margin
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: Image.asset(
            doctor['image'],
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 50),
              );
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Reduce padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctor['specialty'],
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4), // Reduce space
                Text(
                  doctor['description'],
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), // Reduce padding
          child: ElevatedButton(
            onPressed: () => _bookAppointment(doctor),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduce button padding
            ),
            child: const Text(
              'Book',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76), // Fixed: Using withAlpha instead of withOpacity
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.science_outlined),
              label: 'Tests',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _performSearch(String query) {
    if (query.isEmpty) return;

    // Implement search functionality
    _logger.info('Searching for: $query'); // Using logger instead of print

    // Clear search field after search
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _openGoogleLens() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Lens'),
        content: const Text('Open camera for visual search'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement camera functionality
              _logger.info('Opening camera for visual search');
            },
            child: const Text('Open Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: const Icon(Icons.notifications, color: Colors.blue),
                      ),
                      title: Text('Notification ${index + 1}'),
                      subtitle: const Text('This is a notification message'),
                      trailing: Text('${index + 1}h ago'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

void _navigateToPage(int index) {
  switch (index) {
    case 0:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  DoctorsListPage()),
      );
      break;
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MedicinePage()),
      );
      break;
    case 3: // Navigate to Laboratories Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LabTestsApp()),
      );
      break;
    case 4: // Navigate to AI Assistant Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
      break;
    case 5: // Navigate to Test Results Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TestResults()),
      );
      break;
    default:
      _logger.info('Navigate to feature $index');
  }
}




  void _toggleFilter() {
    setState(() {
      _isFilterActive = !_isFilterActive;
    });

    if (_isFilterActive) {
      _showFilterOptions();
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Specialty'),
            Wrap(
              spacing: 8,
              children: [
                'All',
                'Rheumatologist',
                'Dermatologist',
                'Cardiologist',
                'Neurologist',
              ].map((specialty) {
                return ChoiceChip(
                  label: Text(specialty),
                  selected: specialty == 'All',
                  onSelected: (selected) {
                    Navigator.pop(context);
                    // Apply filter based on specialty
                    _logger.info('Filter selected: $specialty');
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Availability'),
            Wrap(
              spacing: 8,
              children: [
                'Any time',
                'Today',
                'Tomorrow',
                'This week',
              ].map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: time == 'Any time',
                  onSelected: (selected) {
                    Navigator.pop(context);
                    // Apply filter based on time
                    _logger.info('Time filter selected: $time');
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    // Implement booking functionality
    _logger.info('Booking appointment with ${doctor['name']}'); // Using logger instead of print

    // Show booking confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment request sent to ${doctor["name"]}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Define the theme color based on selected tab
    final Color themeColor;
    switch (index) {
      case 0:
        themeColor = Colors.purple;
        break;
      case 1:
        themeColor = Colors.teal;
        break;
      case 2:
        themeColor = Colors.blue;
        break;
      case 3:
        themeColor = Colors.amber;
        break;
      case 4:
        themeColor = Colors.red;
        break;
      default:
        themeColor = Colors.blue;
    }
    
    // Use the theme color
    _logger.info('Changed theme color to: $themeColor');
    
    // Implementation with a theme provider would look like:
    // Provider.of<ThemeProvider>(context, listen: false).updateColor(themeColor);
  }
}