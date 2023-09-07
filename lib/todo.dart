import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo{
  
  Todo({required this.toDoTitle,required this.isDone});

  @HiveField(0)
  String toDoTitle;

  @HiveField(1)
  bool isDone;
}