import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final ValueChanged<String>? onToggle;
  final ValueChanged<String>? onDelete;

  const TodoList({
    super.key,
    required this.todos,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(
        child: Text(
          'No todos yet. Add one to get started!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(
          todo: todo,
          onToggle: onToggle ?? (_) {},
          onDelete: onDelete ?? (_) {},
        );
      },
    );
  }
}

