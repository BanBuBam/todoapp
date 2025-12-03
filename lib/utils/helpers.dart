import 'package:flutter/material.dart';
import '../todo_model.dart';

Map<TodoCategory, dynamic> categoryInfo = {
  TodoCategory.work: {
    'icon': Icons.work,
    'name': 'Công việc',
    'color': Colors.blue,
  },
  TodoCategory.personal: {
    'icon': Icons.person,
    'name': 'Cá nhân',
    'color': Colors.purple,
  },
  TodoCategory.study: {
    'icon': Icons.school,
    'name': 'Học tập',
    'color': Colors.orange,
  },
  TodoCategory.shopping: {
    'icon': Icons.shopping_cart,
    'name': 'Mua sắm',
    'color': Colors.pink,
  },
  TodoCategory.health: {
    'icon': Icons.fitness_center,
    'name': 'Sức khỏe',
    'color': Colors.green,
  },
  TodoCategory.other: {
    'icon': Icons.bookmark,
    'name': 'Khác',
    'color': Colors.grey,
  },
};

// Hàm so sánh ngày
bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

// Màu sắc theo mức độ ưu tiên
Color getPriorityColor(Priority p) {
  switch (p) {
    case Priority.high:
      return Colors.red;
    case Priority.medium:
      return Colors.amber;
    case Priority.low:
      return Colors.green;
  }
}

// Text hiển thị mức độ ưu tiên
String getPriorityText(Priority p) {
  switch (p) {
    case Priority.high:
      return 'Cao';
    case Priority.medium:
      return 'TB';
    case Priority.low:
      return 'Thấp';
  }
}
