import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../todo_model.dart';
import '../../utils/helpers.dart';
import '../widgets/todo_card.dart'; // Import TodoCard để dùng lại

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