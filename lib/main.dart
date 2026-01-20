import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness Check',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CheckInScreen(),
    );
  }
}

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  List<DateTime> _checkInHistory = [];
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _startPeriodicReminders();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicReminders() {
    _reminderTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      _showReminderNotification();
    });
  }

  void _showReminderNotification() {
    if (_checkInHistory.isEmpty || 
        DateTime.now().difference(_checkInHistory.last) > Duration(hours: 4)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Check-in Reminder'),
          content: Text('Please confirm your wellness status'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _checkIn() {
    setState(() {
      _checkInHistory.add(DateTime.now());
    });
  }

  String _formatTime(DateTime dt) => DateFormat('MMM d, h:mm a').format(dt);

  Color _getStatusColor() {
    if (_checkInHistory.isEmpty) return Colors.red;
    final lastCheckIn = _checkInHistory.last;
    return DateTime.now().difference(lastCheckIn) < Duration(hours: 4)
        ? Colors.green
        : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wellness Check')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: _getStatusColor()),
                        SizedBox(width: 10),
                        Text(
                          _checkInHistory.isEmpty
                              ? 'No recent check-ins'
                              : 'Last check-in: ${_formatTime(_checkInHistory.last)}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.check),
                      label: Text('Check In Now'),
                      onPressed: _checkIn,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Check-in History:', style: Theme.of(context).textTheme.headline6),
            Expanded(
              child: ListView.builder(
                itemCount: _checkInHistory.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _checkInHistory.length - 1 - index;
                  return ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(_formatTime(_checkInHistory[reversedIndex])),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}