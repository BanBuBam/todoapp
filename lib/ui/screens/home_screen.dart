import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../todo_model.dart';
import '../../utils/helpers.dart';
import '../widgets/todo_card.dart';
import 'calendar_screen.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late Box<TodoItem> _todoBox;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  TodoCategory? _selectedCategoryFilter;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _todoBox = Hive.box<TodoItem>('todoBox');
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  List<TodoItem> _getFilteredTodos() {
    final allTodos = _todoBox.values.toList();
    final filtered = allTodos.where((item) {
      bool matchesSearch = item.title.toLowerCase().contains(_searchText);
      bool matchesCategory =
          _selectedCategoryFilter == null ||
          item.category == _selectedCategoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
    filtered.sort((a, b) {
      int dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return b.priority.index.compareTo(a.priority.index);
    });
    return filtered;
  }

  void _addTodoItem(
    String title,
    DateTime pickedDate,
    Priority pickedPriority,
    TodoCategory pickedCategory,
  ) {
    if (title.isNotEmpty) {
      final newItem = TodoItem(
        id: DateTime.now().toString(),
        title: title,
        date: pickedDate,
        priority: pickedPriority,
        category: pickedCategory,
      );
      _todoBox.add(newItem);
    }
  }

  void _displayAddDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    Priority selectedPriority = Priority.medium;
    TodoCategory selectedCategory = TodoCategory.work;
    _textFieldController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Thêm công việc mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _textFieldController,
                      decoration: const InputDecoration(
                        labelText: "Nội dung",
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime(2100),
                              locale: const Locale('vi', 'VN'),
                            );
                            if (picked != null)
                              setStateDialog(() => selectedDate = picked);
                          },
                          child: const Text('Đổi'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        const Text("Mức độ: "),
                        const Spacer(),
                        DropdownButton<Priority>(
                          value: selectedPriority,
                          onChanged: (val) =>
                              setStateDialog(() => selectedPriority = val!),
                          items: Priority.values
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(getPriorityText(p)),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category, color: Colors.purple),
                        const SizedBox(width: 8),
                        const Text("Chủ đề: "),
                        const Spacer(),
                        DropdownButton<TodoCategory>(
                          value: selectedCategory,
                          onChanged: (val) =>
                              setStateDialog(() => selectedCategory = val!),
                          items: TodoCategory.values
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Icon(
                                        categoryInfo[c]['icon'],
                                        size: 16,
                                        color: categoryInfo[c]['color'],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(categoryInfo[c]['name']),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Lưu'),
                  onPressed: () {
                    _addTodoItem(
                      _textFieldController.text,
                      selectedDate,
                      selectedPriority,
                      selectedCategory,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.teal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: _selectedCategoryFilter == null,
                        onSelected: (bool selected) =>
                            setState(() => _selectedCategoryFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...TodoCategory.values.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              categoryInfo[category]['icon'],
                              size: 18,
                              color: _selectedCategoryFilter == category
                                  ? Colors.white
                                  : categoryInfo[category]['color'],
                            ),
                            label: Text(categoryInfo[category]['name']),
                            selected: _selectedCategoryFilter == category,
                            selectedColor: Colors.teal.shade700,
                            labelStyle: TextStyle(
                              color: _selectedCategoryFilter == category
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onSelected: (bool selected) => setState(
                              () => _selectedCategoryFilter = selected
                                  ? category
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _todoBox.listenable(),
              builder: (context, Box<TodoItem> box, _) {
                final displayTodos = _getFilteredTodos();

                if (displayTodos.isEmpty) {
                  return const Center(child: Text("Không có công việc nào!"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayTodos.length,
                  itemBuilder: (context, index) {
                    final todo = displayTodos[index];
                    return TodoCard(
                      todo: todo,
                      onToggle: () {
                        todo.isDone = !todo.isDone;
                        todo.save();
                      },
                      onDelete: () {
                        todo.delete();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayAddDialog(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
