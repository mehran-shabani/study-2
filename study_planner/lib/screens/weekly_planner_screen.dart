import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:study_planner/models/lesson.dart';
import 'package:study_planner/models/study_plan.dart';

class WeeklyPlannerScreen extends StatelessWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = Jalali.now();
    final studyPlanBox = Hive.box<StudyPlan>('study_plans');

    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامه‌ریزی هفتگی'),
      ),
      body: ValueListenableBuilder(
        valueListenable: studyPlanBox.listenable(),
        builder: (context, Box<StudyPlan> box, _) {
          return PageView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = now.addDays(index);
              final plansForDay = box.values
                  .where((plan) =>
                      Jalali.fromDateTime(plan.date).distanceTo(day) == 0)
                  .toList();

              return _buildDayView(context, day, plansForDay);
            },
          );
        },
      ),
    );
  }

  Widget _buildDayView(
      BuildContext context, Jalali day, List<StudyPlan> plans) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${day.formatter.wN} ${day.day} ${day.formatter.mN}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: plans.isEmpty
              ? const Center(
                  child: Text('برنامه‌ای برای این روز ثبت نشده است.'),
                )
              : ListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(plans[index].lesson.name),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: () => _showAddPlanDialog(context, day.toDateTime()),
            child: const Icon(Icons.add),
          ),
        )
      ],
    );
  }

  void _showAddPlanDialog(BuildContext context, DateTime date) {
    final lessonBox = Hive.box<Lesson>('lessons');
    Lesson? selectedLesson;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('افزودن برنامه'),
          content: DropdownButtonFormField<Lesson>(
            hint: const Text('درس را انتخاب کنید'),
            items: lessonBox.values.map((lesson) {
              return DropdownMenuItem<Lesson>(
                value: lesson,
                child: Text(lesson.name),
              );
            }).toList(),
            onChanged: (value) {
              selectedLesson = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedLesson != null) {
                  final newPlan = StudyPlan()
                    ..date = date
                    ..lesson = selectedLesson!;
                  Hive.box<StudyPlan>('study_plans').add(newPlan);
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
