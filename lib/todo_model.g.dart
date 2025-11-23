// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoItemAdapter extends TypeAdapter<TodoItem> {
  @override
  final int typeId = 0;

  @override
  TodoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoItem(
      id: fields[0] as String,
      title: fields[1] as String,
      isDone: fields[2] as bool,
      date: fields[3] as DateTime,
      priority: fields[4] as Priority,
      category: fields[5] as TodoCategory,
    );
  }

  @override
  void write(BinaryWriter writer, TodoItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isDone)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 1;

  @override
  Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Priority.low;
      case 1:
        return Priority.medium;
      case 2:
        return Priority.high;
      default:
        return Priority.low;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch (obj) {
      case Priority.low:
        writer.writeByte(0);
        break;
      case Priority.medium:
        writer.writeByte(1);
        break;
      case Priority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TodoCategoryAdapter extends TypeAdapter<TodoCategory> {
  @override
  final int typeId = 2;

  @override
  TodoCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoCategory.work;
      case 1:
        return TodoCategory.personal;
      case 2:
        return TodoCategory.study;
      case 3:
        return TodoCategory.shopping;
      case 4:
        return TodoCategory.health;
      case 5:
        return TodoCategory.other;
      default:
        return TodoCategory.work;
    }
  }

  @override
  void write(BinaryWriter writer, TodoCategory obj) {
    switch (obj) {
      case TodoCategory.work:
        writer.writeByte(0);
        break;
      case TodoCategory.personal:
        writer.writeByte(1);
        break;
      case TodoCategory.study:
        writer.writeByte(2);
        break;
      case TodoCategory.shopping:
        writer.writeByte(3);
        break;
      case TodoCategory.health:
        writer.writeByte(4);
        break;
      case TodoCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
