import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import Provider

import '../../todo_model.dart';
import '../../utils/helpers.dart';
import '../../providers/todo_provider.dart'; // Import Provider Class
import '../widgets/todo_card.dart';
import 'calendar_screen.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // Không cần khai báo Box hay biến filter ở đây nữa vì đã có trong Provider
  // Chỉ giữ lại Controller cho các TextField UI
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Lắng nghe ô tìm kiếm để gọi hàm updateSearchText trong Provider
    _searchController.addListener(() {
      context.read<TodoProvider>().updateSearchText(_searchController.text);
    });
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _searchController.dispose();
    super.dispose();
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
                      decoration: const InputDecoration(labelText: "Nội dung", border: OutlineInputBorder()),
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
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime(2100),
                              locale: const Locale('vi', 'VN'),
                            );
                            if (picked != null) setStateDialog(() => selectedDate = picked);
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
                          onChanged: (val) => setStateDialog(() => selectedPriority = val!),
                          items: Priority.values.map((p) => DropdownMenuItem(value: p, child: Text(getPriorityText(p)))).toList(),
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
                          onChanged: (val) => setStateDialog(() => selectedCategory = val!),
                          items: TodoCategory.values.map((c) => DropdownMenuItem(
                            value: c,
                            child: Row(children: [Icon(categoryInfo[c]['icon'], size: 16, color: categoryInfo[c]['color']), const SizedBox(width: 8), Text(categoryInfo[c]['name'])]),
                          )).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(child: const Text('Hủy'), onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  child: const Text('Lưu'),
                  onPressed: () {
                    if (_textFieldController.text.isNotEmpty) {
                      // GỌI PROVIDER ĐỂ THÊM CÔNG VIỆC
                      context.read<TodoProvider>().addTodo(
                          _textFieldController.text,
                          selectedDate,
                          selectedPriority,
                          selectedCategory
                      );
                    }
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
        title: const Text('Hive Todo App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage())),
          )
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),

                // Dùng Consumer để rebuild phần Filter Chip khi categoryFilter thay đổi
                Consumer<TodoProvider>(
                    builder: (context, provider, child) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Tất cả'),
                              selected: provider.categoryFilter == null,
                              onSelected: (bool selected) {
                                provider.updateCategoryFilter(null);
                              },
                            ),
                            const SizedBox(width: 8),
                            ...TodoCategory.values.map((category) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                avatar: Icon(categoryInfo[category]['icon'], size: 18, color: provider.categoryFilter == category ? Colors.white : categoryInfo[category]['color']),
                                label: Text(categoryInfo[category]['name']),
                                selected: provider.categoryFilter == category,
                                selectedColor: Colors.teal.shade700,
                                labelStyle: TextStyle(color: provider.categoryFilter == category ? Colors.white : Colors.black),
                                onSelected: (bool selected) {
                                  provider.updateCategoryFilter(selected ? category : null);
                                },
                              ),
                            )),
                          ],
                        ),
                      );
                    }
                ),
              ],
            ),
          ),

          // Danh sách công việc
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                final displayTodos = provider.filteredTodos; // Lấy list đã lọc từ Provider

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
                      onToggle: () => provider.toggleTodoStatus(todo),
                      onDelete: () => provider.deleteTodo(todo),
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