import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

// Import file model (Nơi chứa định nghĩa chuẩn của Priority và TodoCategory)
import 'todo_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  await Hive.initFlutter();

  Hive.registerAdapter(TodoItemAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(TodoCategoryAdapter());

  await Hive.openBox<TodoItem>('todoBox');

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      locale: const Locale('vi', 'VN'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN')],
      home: const TodoListPage(),
    );
  }
}

// --- HELPERS UI ---
// (LƯU Ý: Không định nghĩa enum Priority và TodoCategory ở đây nữa vì đã có trong todo_model.dart)

Map<TodoCategory, dynamic> categoryInfo = {
  TodoCategory.work: {'icon': Icons.work, 'name': 'Công việc', 'color': Colors.blue},
  TodoCategory.personal: {'icon': Icons.person, 'name': 'Cá nhân', 'color': Colors.purple},
  TodoCategory.study: {'icon': Icons.school, 'name': 'Học tập', 'color': Colors.orange},
  TodoCategory.shopping: {'icon': Icons.shopping_cart, 'name': 'Mua sắm', 'color': Colors.pink},
  TodoCategory.health: {'icon': Icons.fitness_center, 'name': 'Sức khỏe', 'color': Colors.green},
  TodoCategory.other: {'icon': Icons.bookmark, 'name': 'Khác', 'color': Colors.grey},
};

bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

Color getPriorityColor(Priority p) {
  switch (p) {
    case Priority.high: return Colors.red;
    case Priority.medium: return Colors.amber;
    case Priority.low: return Colors.green;
  }
}

String getPriorityText(Priority p) {
  switch (p) {
    case Priority.high: return 'Cao';
    case Priority.medium: return 'TB';
    case Priority.low: return 'Thấp';
  }
}

// --- MÀN HÌNH CHÍNH ---

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
      bool matchesCategory = _selectedCategoryFilter == null || item.category == _selectedCategoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    filtered.sort((a, b) {
      int dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return b.priority.index.compareTo(a.priority.index);
    });

    return filtered;
  }

  void _addTodoItem(String title, DateTime pickedDate, Priority pickedPriority, TodoCategory pickedCategory) {
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
                    _addTodoItem(_textFieldController.text, selectedDate, selectedPriority, selectedCategory);
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: _selectedCategoryFilter == null,
                        onSelected: (bool selected) => setState(() => _selectedCategoryFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...TodoCategory.values.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          avatar: Icon(categoryInfo[category]['icon'], size: 18, color: _selectedCategoryFilter == category ? Colors.white : categoryInfo[category]['color']),
                          label: Text(categoryInfo[category]['name']),
                          selected: _selectedCategoryFilter == category,
                          selectedColor: Colors.teal.shade700,
                          labelStyle: TextStyle(color: _selectedCategoryFilter == category ? Colors.white : Colors.black),
                          onSelected: (bool selected) => setState(() => _selectedCategoryFilter = selected ? category : null),
                        ),
                      )),
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

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Box<TodoItem> _todoBox;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _todoBox = Hive.box<TodoItem>('todoBox');
    _selectedDay = _focusedDay;
  }

  List<TodoItem> _getEventsForDay(DateTime day) {
    return _todoBox.values.where((todo) => isSameDate(todo.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch trình', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: const BackButton(color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: _todoBox.listenable(),
        builder: (context, box, _) {
          return Column(
            children: [
              TableCalendar<TodoItem>(
                locale: 'vi_VN',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDate(_selectedDay!, day),
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDate(_selectedDay!, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: _getEventsForDay(_selectedDay!).map((todo) {
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
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TodoCard extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoCard({super.key, required this.todo, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final catInfo = categoryInfo[todo.category];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: getPriorityColor(todo.priority).withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (v) => onToggle(),
          activeColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: catInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(catInfo['icon'], size: 12, color: catInfo['color']),
                      const SizedBox(width: 4),
                      Text(catInfo['name'], style: TextStyle(fontSize: 11, color: catInfo['color'], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_month, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(DateFormat('dd/MM/yyyy').format(todo.date), style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ],
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
      ),
    );
  }
}