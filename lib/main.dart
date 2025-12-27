import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- REQUIREMENT: SECURE LOGIN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String _correctPin = "1234"; // Default PIN for Project 5

  void _login() {
    if (_pinController.text == _correctPin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DiaryDashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect PIN! Try 1234")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            const Text("Digital Diary Access", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Enter your secure PIN to continue", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(
              controller: _pinController,
              obscureText: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                hintText: "****",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Unlock Diary"),
            )
          ],
        ),
      ),
    );
  }
}

// --- REQUIREMENT: CRUD & CALENDAR VIEW ---
class DiaryDashboard extends StatefulWidget {
  const DiaryDashboard({super.key});
  @override
  State<DiaryDashboard> createState() => _DiaryDashboardState();
}

class _DiaryDashboardState extends State<DiaryDashboard> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final List<Map<String, String>> _diaryEntries = [];

  // Create & Edit Logic
  void _showEntryDialog({int? index}) {
    final titleCtrl = TextEditingController(text: index != null ? _diaryEntries[index]['title'] : "");
    final bodyCtrl = TextEditingController(text: index != null ? _diaryEntries[index]['content'] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? "New Diary Entry" : "Edit Entry"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: "Thoughts..."), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (index == null) {
                  _diaryEntries.add({
                    'title': titleCtrl.text,
                    'content': bodyCtrl.text,
                    'date': DateFormat('dd MMM yyyy').format(_selectedDay),
                  });
                } else {
                  _diaryEntries[index] = {
                    'title': titleCtrl.text,
                    'content': bodyCtrl.text,
                    'date': _diaryEntries[index]['date']!,
                  };
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Digital Diary"), centerTitle: true),
      body: Column(
        children: [
          // REQUIREMENT: Calendar View
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(selectedDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _diaryEntries.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(_diaryEntries[i]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${_diaryEntries[i]['date']}\n${_diaryEntries[i]['content']}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEntryDialog(index: i)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _diaryEntries.removeAt(i))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showEntryDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}