import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/todo_service.dart';
import '../widgets/todo_list.dart';
import '../widgets/add_todo_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          Consumer<TodoService>(
            builder: (context, service, _) {
              final completedCount = service.getCompletedCount();
              final pendingCount = service.getPendingCount();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text('Pending: $pendingCount'),
                      backgroundColor: Colors.orange.shade100,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('Completed: $completedCount'),
                      backgroundColor: Colors.green.shade100,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoService>(
        builder: (context, service, _) {
          return Column(
            children: [
              // Filter and Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search todos...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          service.searchTodos(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // TODO: Show filter dialog
                      },
                    ),
                  ],
                ),
              ),
              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                      label: 'Overdue',
                      count: service.getOverdueCount(),
                      color: Colors.red,
                    ),
                    _StatChip(
                      label: 'Due Soon',
                      count: service.getDueSoonCount(),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Todo List
              Expanded(
                child: TodoList(
                  todos: service.filteredTodos.isEmpty
                      ? service.todos
                      : service.filteredTodos,
                  onToggle: (id) => service.toggleTodoCompletion(id),
                  onDelete: (id) => service.deleteTodo(id),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTodoDialog(
              onSubmit: (title, description,
                  {priority, category, dueDate}) {
                context.read<TodoService>().addTodo(
                      title,
                      description,
                      priority: priority,
                      category: category,
                      dueDate: dueDate,
                    );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }
}

