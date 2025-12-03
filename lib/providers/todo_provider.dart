import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../todo_model.dart';
import '../utils/helpers.dart'; // Để dùng hàm isSameDate

class TodoProvider extends ChangeNotifier {
  late Box<TodoItem> _box;

  // Các biến trạng thái để lọc
  String _searchText = '';
  TodoCategory? _categoryFilter;

  TodoProvider() {
    _box = Hive.box<TodoItem>('todoBox');

    // Lắng nghe thay đổi từ Hive để tự động cập nhật UI
    _box.listenable().addListener(() {
      notifyListeners();
    });
  }

  // --- Getters (Lấy dữ liệu) ---

  // Lấy danh sách đã lọc và sắp xếp cho Màn hình chính
  List<TodoItem> get filteredTodos {
    var todos = _box.values.toList();

    // 1. Lọc theo danh mục
    if (_categoryFilter != null) {
      todos = todos.where((t) => t.category == _categoryFilter).toList();
    }

    // 2. Lọc theo từ khóa tìm kiếm
    if (_searchText.isNotEmpty) {
      todos = todos.where((t) => t.title.toLowerCase().contains(_searchText)).toList();
    }

    // 3. Sắp xếp: Ngày tăng dần -> Độ ưu tiên giảm dần
    todos.sort((a, b) {
      int dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return b.priority.index.compareTo(a.priority.index);
    });

    return todos;
  }

  // Lấy danh sách công việc theo ngày (cho Màn hình Lịch)
  List<TodoItem> getTodosForDay(DateTime day) {
    return _box.values.where((todo) => isSameDate(todo.date, day)).toList();
  }

  // Getter cho trạng thái filter hiện tại (để UI hiển thị đúng màu nút/chip)
  String get searchText => _searchText;
  TodoCategory? get categoryFilter => _categoryFilter;

  // --- Actions (Hành động thay đổi dữ liệu) ---

  void updateSearchText(String text) {
    _searchText = text.toLowerCase();
    notifyListeners();
  }

  void updateCategoryFilter(TodoCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void addTodo(String title, DateTime date, Priority priority, TodoCategory category) {
    final newItem = TodoItem(
      id: DateTime.now().toString(),
      title: title,
      date: date,
      priority: priority,
      category: category,
    );
    _box.add(newItem);
    // notifyListeners() được gọi tự động nhờ listener trong constructor
  }

  void toggleTodoStatus(TodoItem todo) {
    todo.isDone = !todo.isDone;
    todo.save();
  }

  void deleteTodo(TodoItem todo) {
    todo.delete();
  }
}