import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/priority.dart';

/// Test fixtures and factories for creating test data
/// This is a common pattern in real-world TDD to avoid duplication
class TodoFixtures {
  static Todo createTodo({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? 'test-id-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Test Todo',
      description: description ?? 'Test Description',
      isCompleted: isCompleted ?? false,
      priority: priority ?? Priority.medium,
      category: category ?? '',
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  static Todo createCompletedTodo({String? id, String? title}) {
    return createTodo(id: id, title: title, isCompleted: true);
  }

  static Todo createPendingTodo({String? id, String? title}) {
    return createTodo(id: id, title: title, isCompleted: false);
  }

  static Todo createHighPriorityTodo({String? id, String? title}) {
    return createTodo(id: id, title: title, priority: Priority.high);
  }

  static Todo createUrgentTodo({String? id, String? title}) {
    return createTodo(id: id, title: title, priority: Priority.urgent);
  }

  static Todo createOverdueTodo({String? id, String? title}) {
    return createTodo(
      id: id,
      title: title,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  static Todo createDueSoonTodo({String? id, String? title}) {
    return createTodo(
      id: id,
      title: title,
      dueDate: DateTime.now().add(const Duration(hours: 12)),
    );
  }

  static Todo createWorkTodo({String? id, String? title, Priority? priority}) {
    return createTodo(
      id: id,
      title: title,
      category: 'Work',
      priority: priority,
    );
  }

  static Todo createPersonalTodo({
    String? id,
    String? title,
    Priority? priority,
  }) {
    return createTodo(
      id: id,
      title: title,
      category: 'Personal',
      priority: priority,
    );
  }

  static List<Todo> createMultipleTodos(int count, {String? prefix}) {
    return List.generate(
      count,
      (index) => createTodo(
        id: 'todo-$index',
        title: '${prefix ?? 'Todo'} $index',
        description: 'Description $index',
      ),
    );
  }

  static List<Todo> createMixedTodos() {
    return [
      createCompletedTodo(id: '1', title: 'Completed Task'),
      createPendingTodo(id: '2', title: 'Pending Task'),
      createHighPriorityTodo(id: '3', title: 'High Priority Task'),
      createUrgentTodo(id: '4', title: 'Urgent Task'),
      createOverdueTodo(id: '5', title: 'Overdue Task'),
      createDueSoonTodo(id: '6', title: 'Due Soon Task'),
      createWorkTodo(id: '7', title: 'Work Task'),
      createPersonalTodo(id: '8', title: 'Personal Task'),
    ];
  }
}
