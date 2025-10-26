import 'package:flutter/material.dart';
import 'package:study_planner/screens/lesson_screen.dart';
import 'package:study_planner/screens/stats_screen.dart';
import 'package:study_planner/screens/study_timer_screen.dart';

class MainHostScreen extends StatefulWidget {
  const MainHostScreen({super.key});

  @override
  State<MainHostScreen> createState() => _MainHostScreenState();
}

class _MainHostScreenState extends State<MainHostScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    LessonScreen(),
    StudyTimerScreen(),
    StatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'دروس',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'تایمر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'آمار',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
