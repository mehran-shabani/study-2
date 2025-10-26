import 'package:hive/hive.dart';
import 'lesson.dart';

part 'study_session.g.dart';

@HiveType(typeId: 1)
class StudySession extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late Duration duration;

  @HiveField(2)
  late Lesson lesson;
}
