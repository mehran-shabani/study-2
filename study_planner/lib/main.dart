import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_planner/models/lesson.dart';
import 'package:study_planner/models/study_plan.dart';
import 'package:study_planner/models/study_session.dart';
import 'package:study_planner/screens/main_host_screen.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(LessonAdapter());
  Hive.registerAdapter(StudyPlanAdapter());
  Hive.registerAdapter(StudySessionAdapter());

  // Open Boxes
  await Hive.openBox<Lesson>('lessons');
  await Hive.openBox<StudyPlan>('study_plans');
  await Hive.openBox<StudySession>('study_sessions');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainHostScreen(),
    );
  }
}
