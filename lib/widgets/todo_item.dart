import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/priority.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.grey;
      case Priority.medium:
        return Colors.blue;
      case Priority.high:
        return Colors.orange;
      case Priority.urgent:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = todo.isOverdue;
    final isDueSoon = todo.isDueSoon;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOverdue
          ? Colors.red.shade50
          : isDueSoon
              ? Colors.orange.shade50
              : null,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(todo.id),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontWeight: todo.priority == Priority.urgent ||
                          todo.priority == Priority.high
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(todo.priority).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                todo.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: _getPriorityColor(todo.priority),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.description),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                if (todo.category.isNotEmpty)
                  Chip(
                    label: Text(todo.category),
                    labelStyle: const TextStyle(fontSize: 10),
                    padding: EdgeInsets.zero,
                  ),
                if (todo.dueDate != null)
                  Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOverdue
                              ? Icons.warning
                              : isDueSoon
                                  ? Icons.schedule
                                  : Icons.calendar_today,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isOverdue
                                ? Colors.red
                                : isDueSoon
                                    ? Colors.orange
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    labelStyle: const TextStyle(fontSize: 10),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => onDelete(todo.id),
        ),
      ),
    );
  }
}

