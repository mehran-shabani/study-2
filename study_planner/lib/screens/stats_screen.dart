import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_planner/models/lesson.dart';
import 'package:study_planner/models/study_session.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionBox = Hive.box<StudySession>('study_sessions');
    final lessonBox = Hive.box<Lesson>('lessons');

    return Scaffold(
      appBar: AppBar(
        title: const Text('آمار هفتگی'),
      ),
      body: ValueListenableBuilder(
        valueListenable: sessionBox.listenable(),
        builder: (context, Box<StudySession> box, _) {
          final data = _prepareChartData(box, lessonBox);
          if (data.entries.every((e) => e.value == 0)) {
            return const Center(child: Text('اطلاعاتی برای نمایش وجود ندارد.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _calculateMaxY(data),
                barGroups: _createBarGroups(data),
                titlesData: _buildTitlesData(data),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, double> _prepareChartData(Box<StudySession> sessionBox, Box<Lesson> lessonBox) {
    final Map<String, double> data = {};
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    for (var lesson in lessonBox.values) {
      data[lesson.name] = 0;
    }

    final recentSessions = sessionBox.values.where((s) => s.date.isAfter(weekAgo));

    for (var session in recentSessions) {
      final lessonName = (session.lesson as Lesson).name;
      data[lessonName] = (data[lessonName] ?? 0) + session.duration.inMinutes.toDouble();
    }
    return data;
  }

  double _calculateMaxY(Map<String, double> data) {
    if (data.isEmpty) return 0;
    final maxMinutes = data.values.reduce((a, b) => a > b ? a : b);
    if (maxMinutes == 0) return 60; // Default height if no data
    return (maxMinutes * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _createBarGroups(Map<String, double> data) {
    return data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: mapEntry.value,
            color: Colors.amber,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData _buildTitlesData(Map<String, double> data) {
    final lessonNames = data.keys.toList();
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            final text = lessonNames[value.toInt()];
            return Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                text.length > 3 ? text.substring(0, 3) : text,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            );
          },
          reservedSize: 30,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (value == 0 || value == meta.max) return const Text('');
            return Text('${value.toInt()}m');
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
