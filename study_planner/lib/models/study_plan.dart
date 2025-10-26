import 'package:hive/hive.dart';
import 'lesson.dart';

part 'study_plan.g.dart';

@HiveType(typeId: 2)
class StudyPlan extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late Lesson lesson;
}
