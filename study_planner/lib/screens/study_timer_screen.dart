import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:study_planner/models/lesson.dart';
import 'package:study_planner/models/study_session.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _displayTime = "00:00:00";
  bool _isRunning = false;
  Lesson? _selectedLesson;
  final Box<Lesson> _lessonBox = Hive.box<Lesson>('lessons');

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _displayTime =
            '${_stopwatch.elapsed.inHours.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
    _stopwatch.start();
    setState(() => _isRunning = true);
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopwatch.stop();
    setState(() => _isRunning = false);
  }

  void _saveSession() {
    if (_selectedLesson != null && _stopwatch.elapsed.inSeconds > 0) {
      final session = StudySession()
        ..date = DateTime.now()
        ..duration = _stopwatch.elapsed
        ..lesson = _selectedLesson!;

      Hive.box<StudySession>('study_sessions').add(session);

      _stopwatch.reset();
      setState(() => _displayTime = "00:00:00");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جلسه مطالعه ذخیره شد!')),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا یک درس انتخاب کنید و تایمر را اجرا نمایید.')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تایمر مطالعه')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<Lesson>(
              value: _selectedLesson,
              hint: const Text('یک درس را انتخاب کنید'),
              items: _lessonBox.values.map((lesson) {
                return DropdownMenuItem<Lesson>(
                  value: lesson,
                  child: Text(lesson.name),
                );
              }).toList(),
              onChanged: (lesson) {
                setState(() => _selectedLesson = lesson);
              },
            ),
            const SizedBox(height: 50),
            Text(_displayTime, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  child: Text(_isRunning ? 'توقف' : 'شروع'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _saveSession,
                  child: const Text('ذخیره'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
