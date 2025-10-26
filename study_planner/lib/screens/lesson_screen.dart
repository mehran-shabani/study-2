import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_planner/models/lesson.dart';
import 'package:study_planner/screens/weekly_planner_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessonBox = Hive.box<Lesson>('lessons');

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت دروس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyPlannerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: lessonBox.listenable(),
        builder: (context, Box<Lesson> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text('هیچ درسی اضافه نشده است.'),
            );
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final lesson = box.getAt(index) as Lesson;
              return ListTile(
                title: Text(lesson.name),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLessonDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('درس جدید'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'نام درس'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newLesson = Lesson()..name = nameController.text;
                  Hive.box<Lesson>('lessons').add(newLesson);
                  Navigator.pop(context);
                }
              },
              child: const Text('افزودن'),
            ),
          ],
        );
      },
    );
  }
}
