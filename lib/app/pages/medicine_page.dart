import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<dynamic> _medicines = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('http://your-backend-api.com/medicines?date=$_selectedDay'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicines"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(FontAwesomeIcons.pills, size: 50, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select a Date",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                    ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
                    : _medicines.isEmpty
                        ? const Center(child: Text("No medicines found for this date."))
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
        title: Text(medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(dosage),
        trailing: const Icon(Icons.check_circle, color: Colors.blue),
      ),
    );
  }
}
