import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

// Dòng này cực quan trọng, nó liên kết với file code do máy tự sinh ra
part 'todo_model.g.dart';

// Định nghĩa TypeId cho Enum Priority (Mỗi class/enum phải có 1 id riêng, không trùng nhau)
@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

// Định nghĩa TypeId cho Enum Category
@HiveType(typeId: 2)
enum TodoCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  study,
  @HiveField(3)
  shopping,
  @HiveField(4)
  health,
  @HiveField(5)
  other,
}

// Định nghĩa Class chính
@HiveType(typeId: 0)
class TodoItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  Priority priority;

  @HiveField(5)
  TodoCategory category;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.date,
    required this.priority,
    required this.category,
  });
}