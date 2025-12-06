import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/priority.dart';

void main() {
  group('Todo Model', () {
    test('should create a todo with required fields', () {
      // Arrange & Act
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );

      // Assert
      expect(todo.id, '1');
      expect(todo.title, 'Test Todo');
      expect(todo.description, 'Test Description');
      expect(todo.isCompleted, false);
      expect(todo.createdAt, isNotNull);
      expect(todo.priority, Priority.medium);
      expect(todo.category, isEmpty);
      expect(todo.dueDate, isNull);
    });

    test('should create a todo with isCompleted set to true', () {
      // Arrange & Act
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: true,
      );

      // Assert
      expect(todo.isCompleted, true);
    });

    test('should toggle completion status', () {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );

      // Act
      final toggledTodo = todo.toggleCompletion();

      // Assert
      expect(toggledTodo.isCompleted, true);
      expect(todo.isCompleted, false); // Original should remain unchanged
    });

    test('should create a copy with updated fields', () {
      // Arrange
      final originalTodo = Todo(
        id: '1',
        title: 'Original Title',
        description: 'Original Description',
      );

      // Act
      final updatedTodo = originalTodo.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      // Assert
      expect(updatedTodo.id, '1');
      expect(updatedTodo.title, 'Updated Title');
      expect(updatedTodo.description, 'Original Description');
      expect(updatedTodo.isCompleted, true);
      expect(originalTodo.title, 'Original Title'); // Original unchanged
    });

    test('should create a todo with priority, category, and dueDate', () {
      // Arrange & Act
      final dueDate = DateTime.now().add(const Duration(days: 7));
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        priority: Priority.high,
        category: 'Work',
        dueDate: dueDate,
      );

      // Assert
      expect(todo.priority, Priority.high);
      expect(todo.category, 'Work');
      expect(todo.dueDate, dueDate);
    });

    test('should check if todo is overdue', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final overdueTodo = Todo(
        id: '1',
        title: 'Overdue',
        description: 'Test',
        dueDate: pastDate,
      );
      final notOverdueTodo = Todo(
        id: '2',
        title: 'Not Overdue',
        description: 'Test',
        dueDate: futureDate,
      );
      final noDueDateTodo = Todo(
        id: '3',
        title: 'No Due Date',
        description: 'Test',
      );

      // Assert
      expect(overdueTodo.isOverdue, true);
      expect(notOverdueTodo.isOverdue, false);
      expect(noDueDateTodo.isOverdue, false);
    });

    test('should check if todo is due soon', () {
      // Arrange
      final dueSoon = DateTime.now().add(const Duration(hours: 12));
      final notDueSoon = DateTime.now().add(const Duration(days: 3));
      final dueSoonTodo = Todo(
        id: '1',
        title: 'Due Soon',
        description: 'Test',
        dueDate: dueSoon,
      );
      final notDueSoonTodo = Todo(
        id: '2',
        title: 'Not Due Soon',
        description: 'Test',
        dueDate: notDueSoon,
      );

      // Assert
      expect(dueSoonTodo.isDueSoon, true);
      expect(notDueSoonTodo.isDueSoon, false);
    });

    test('should convert to and from JSON with new fields', () {
      // Arrange
      final dueDate = DateTime.now();
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: true,
        priority: Priority.high,
        category: 'Work',
        dueDate: dueDate,
      );

      // Act
      final json = todo.toJson();
      final fromJson = Todo.fromJson(json);

      // Assert
      expect(fromJson.id, todo.id);
      expect(fromJson.title, todo.title);
      expect(fromJson.description, todo.description);
      expect(fromJson.isCompleted, todo.isCompleted);
      expect(fromJson.priority, todo.priority);
      expect(fromJson.category, todo.category);
      expect(
        fromJson.dueDate?.millisecondsSinceEpoch,
        todo.dueDate?.millisecondsSinceEpoch,
      );
    });

    test('should copy with new fields', () {
      // Arrange
      final todo = Todo(id: '1', title: 'Original', description: 'Test');

      // Act
      final updated = todo.copyWith(
        priority: Priority.urgent,
        category: 'Personal',
        dueDate: DateTime.now(),
      );

      // Assert
      expect(updated.priority, Priority.urgent);
      expect(updated.category, 'Personal');
      expect(updated.dueDate, isNotNull);
      expect(todo.priority, Priority.medium); // Original unchanged
    });
  });
}
