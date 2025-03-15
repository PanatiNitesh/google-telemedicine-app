import 'package:flutter/material.dart';

class MedicinesListPage extends StatefulWidget {
  const MedicinesListPage({super.key});

  @override
  State<MedicinesListPage> createState() => _MedicinesListPageState();
}

class _MedicinesListPageState extends State<MedicinesListPage> {
  String _selectedRoutine = 'Morning';
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _filteredMedicines = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    final mockData = [
      {
        'name': 'Cyra D',
        'dosage': '40',
        'instruction': 'Eat Before',
        'routine': 'Morning',
      },
      {
        'name': 'Dolo',
        'dosage': '650 mg',
        'instruction': 'Eat After Breakfast',
        'routine': 'Morning',
      },
      {
        'name': 'Fol',
        'dosage': '5mg',
        'instruction': 'Eat After Breakfast',
        'routine': 'Morning',
      },
      {
        'name': 'Aspirin',
        'dosage': '100mg',
        'instruction': 'Eat After Lunch',
        'routine': 'Afternoon',
      },
      {
        'name': 'Paracetamol',
        'dosage': '500mg',
        'instruction': 'Eat Before Sleep',
        'routine': 'Night',
      },
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

  void _navigateToMedicineDetails(String medicineName) {
    Navigator.pushNamed(
      context,
      '/medicines-list',
      arguments: medicineName, // Pass the medicine name as an argument
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final navBarHeight = screenHeight * (orientation == Orientation.portrait ? 0.12 : 0.18);

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
          'Medicines List',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          10.0,
          screenWidth * 0.04,
          navBarHeight + (screenWidth * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: SizedBox(
                width: screenWidth * 0.6,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    hintStyle: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
                    prefixIcon: Icon(Icons.search, size: screenWidth * 0.05, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _filterBySearch,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(
                value: _selectedRoutine,
                items: <String>['Morning', 'Afternoon', 'Night'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _filterMedicines(newValue);
                  }
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: screenWidth * 0.06,
                  color: Colors.black,
                ),
                underline: Container(),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = _filteredMedicines[index];
                  return GestureDetector(
                    onTap: () => _navigateToMedicineDetails(medicine['name']),
                    child: Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
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
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(screenWidth, navBarHeight),
    );
  }

  Widget _buildBottomNavBar(double screenWidth, double navBarHeight) {
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
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label, double screenWidth) {
    return GestureDetector(
      onTap: () {},
      child: CircleAvatar(
        radius: screenWidth * 0.06,
        backgroundColor: index == 1 ? Colors.blue : Colors.transparent,
        child: Icon(
          icon,
          size: screenWidth * 0.06,
          color: index == 1 ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: MedicinesListPage()));
}