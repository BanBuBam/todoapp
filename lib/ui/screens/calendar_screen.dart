import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:table_calendar/table_calendar.dart';

import '../../todo_model.dart';
import '../../utils/helpers.dart';
import '../../providers/todo_provider.dart'; // Import Provider Class
import '../widgets/todo_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Không cần biến Box nữa
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch trình', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: const BackButton(color: Colors.white),
      ),
      // Dùng Consumer để lắng nghe thay đổi dữ liệu
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          // Lấy danh sách công việc của ngày đang chọn thông qua Provider
          final eventsForSelectedDay = provider.getTodosForDay(_selectedDay!);

          return Column(
            children: [
              TableCalendar<TodoItem>(
                locale: 'vi_VN',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDate(_selectedDay!, day),
                // Sử dụng hàm getTodosForDay từ provider cho eventLoader
                eventLoader: (day) => provider.getTodosForDay(day),
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
                    children: eventsForSelectedDay.map((todo) {
                      return TodoCard(
                        todo: todo,
                        onToggle: () => provider.toggleTodoStatus(todo),
                        onDelete: () => provider.deleteTodo(todo),
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