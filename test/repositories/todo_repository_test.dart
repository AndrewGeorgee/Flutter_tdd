import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/priority.dart';
import 'package:flutter_tdd/models/todo_filter.dart';
import 'package:flutter_tdd/repositories/todo_repository.dart';

void main() {
  group('TodoRepository', () {
    late TodoRepository repository;

    setUp(() {
      repository = TodoRepository();
    });

    test('should return empty list initially', () async {
      // Act
      final todos = await repository.getAllTodos();

      // Assert
      expect(todos, isEmpty);
    });

    test('should add a todo', () async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );

      // Act
      await repository.addTodo(todo);
      final todos = await repository.getAllTodos();

      // Assert
      expect(todos.length, 1);
      expect(todos.first.id, '1');
      expect(todos.first.title, 'Test Todo');
    });

    test('should get a todo by id', () async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );
      await repository.addTodo(todo);

      // Act
      final foundTodo = await repository.getTodoById('1');

      // Assert
      expect(foundTodo, isNotNull);
      expect(foundTodo?.id, '1');
      expect(foundTodo?.title, 'Test Todo');
    });

    test('should return null when todo not found', () async {
      // Act
      final foundTodo = await repository.getTodoById('non-existent');

      // Assert
      expect(foundTodo, isNull);
    });

    test('should update a todo', () async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Original Title',
        description: 'Original Description',
      );
      await repository.addTodo(todo);

      final updatedTodo = todo.copyWith(title: 'Updated Title');

      // Act
      await repository.updateTodo(updatedTodo);
      final todos = await repository.getAllTodos();

      // Assert
      expect(todos.length, 1);
      expect(todos.first.title, 'Updated Title');
    });

    test('should delete a todo', () async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );
      await repository.addTodo(todo);

      // Act
      await repository.deleteTodo('1');
      final todos = await repository.getAllTodos();

      // Assert
      expect(todos, isEmpty);
    });

    test('should get completed todos', () async {
      // Arrange
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        description: 'Description 1',
        isCompleted: true,
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        description: 'Description 2',
        isCompleted: false,
      );
      await repository.addTodo(todo1);
      await repository.addTodo(todo2);

      // Act
      final completedTodos = await repository.getCompletedTodos();

      // Assert
      expect(completedTodos.length, 1);
      expect(completedTodos.first.id, '1');
    });

    test('should get pending todos', () async {
      // Arrange
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        description: 'Description 1',
        isCompleted: true,
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        description: 'Description 2',
        isCompleted: false,
      );
      await repository.addTodo(todo1);
      await repository.addTodo(todo2);

      // Act
      final pendingTodos = await repository.getPendingTodos();

      // Assert
      expect(pendingTodos.length, 1);
      expect(pendingTodos.first.id, '2');
    });

    test('should search todos by title', () async {
      // Arrange
      await repository.addTodo(
        Todo(id: '1', title: 'Buy grocery items', description: 'Milk and eggs'),
      );
      await repository.addTodo(
        Todo(
          id: '2',
          title: 'Call dentist',
          description: 'Schedule appointment',
        ),
      );
      await repository.addTodo(
        Todo(id: '3', title: 'Grocery shopping', description: 'Vegetables'),
      );

      // Act
      final results = await repository.searchTodos('grocery');

      // Assert
      expect(results.length, 2);
      expect(results.any((t) => t.id == '1'), true);
      expect(results.any((t) => t.id == '3'), true);
    });

    test('should filter todos by category', () async {
      // Arrange
      await repository.addTodo(
        Todo(
          id: '1',
          title: 'Work Task',
          description: 'Test',
          category: 'Work',
        ),
      );
      await repository.addTodo(
        Todo(
          id: '2',
          title: 'Personal Task',
          description: 'Test',
          category: 'Personal',
        ),
      );
      await repository.addTodo(
        Todo(
          id: '3',
          title: 'Another Work Task',
          description: 'Test',
          category: 'Work',
        ),
      );

      // Act
      final workTodos = await repository.getTodosByCategory('Work');

      // Assert
      expect(workTodos.length, 2);
      expect(workTodos.every((t) => t.category == 'Work'), true);
    });

    test('should filter todos by priority', () async {
      // Arrange
      await repository.addTodo(
        Todo(
          id: '1',
          title: 'Urgent Task',
          description: 'Test',
          priority: Priority.urgent,
        ),
      );
      await repository.addTodo(
        Todo(
          id: '2',
          title: 'Low Task',
          description: 'Test',
          priority: Priority.low,
        ),
      );
      await repository.addTodo(
        Todo(
          id: '3',
          title: 'Another Urgent',
          description: 'Test',
          priority: Priority.urgent,
        ),
      );

      // Act
      final urgentTodos = await repository.getTodosByPriority(Priority.urgent);

      // Assert
      expect(urgentTodos.length, 2);
      expect(urgentTodos.every((t) => t.priority == Priority.urgent), true);
    });

    test('should get overdue todos', () async {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));
      await repository.addTodo(
        Todo(id: '1', title: 'Overdue', description: 'Test', dueDate: pastDate),
      );
      await repository.addTodo(
        Todo(
          id: '2',
          title: 'Not Overdue',
          description: 'Test',
          dueDate: futureDate,
        ),
      );
      await repository.addTodo(
        Todo(id: '3', title: 'No Due Date', description: 'Test'),
      );

      // Act
      final overdueTodos = await repository.getOverdueTodos();

      // Assert
      expect(overdueTodos.length, 1);
      expect(overdueTodos.first.id, '1');
    });

    test('should get todos due soon', () async {
      // Arrange
      final dueSoon = DateTime.now().add(const Duration(hours: 12));
      final notDueSoon = DateTime.now().add(const Duration(days: 3));
      await repository.addTodo(
        Todo(id: '1', title: 'Due Soon', description: 'Test', dueDate: dueSoon),
      );
      await repository.addTodo(
        Todo(
          id: '2',
          title: 'Not Due Soon',
          description: 'Test',
          dueDate: notDueSoon,
        ),
      );

      // Act
      final dueSoonTodos = await repository.getDueSoonTodos();

      // Assert
      expect(dueSoonTodos.length, 1);
      expect(dueSoonTodos.first.id, '1');
    });

    test('should get all categories', () async {
      // Arrange
      await repository.addTodo(
        Todo(id: '1', title: 'Task 1', description: 'Test', category: 'Work'),
      );
      await repository.addTodo(
        Todo(
          id: '2',
          title: 'Task 2',
          description: 'Test',
          category: 'Personal',
        ),
      );
      await repository.addTodo(
        Todo(id: '3', title: 'Task 3', description: 'Test', category: 'Work'),
      );

      // Act
      final categories = await repository.getAllCategories();

      // Assert
      expect(categories.length, 2);
      expect(categories.contains('Work'), true);
      expect(categories.contains('Personal'), true);
    });

    test('should filter and sort todos', () async {
      // Arrange
      await repository.addTodo(
        Todo(
          id: '1',
          title: 'Low Priority',
          description: 'Test',
          priority: Priority.low,
          category: 'Work',
        ),
      );
      await repository.addTodo(
        Todo(
          id: '2',
          title: 'High Priority',
          description: 'Test',
          priority: Priority.high,
          category: 'Work',
        ),
      );
      await repository.addTodo(
        Todo(
          id: '3',
          title: 'Medium Priority',
          description: 'Test',
          priority: Priority.medium,
          category: 'Personal',
        ),
      );

      final filter = TodoFilter(
        filterBy: TodoFilterBy.byCategory,
        category: 'Work',
        sortBy: TodoSortBy.priority,
        sortAscending: false,
      );

      // Act
      final filtered = await repository.filterAndSortTodos(filter);

      // Assert
      expect(filtered.length, 2);
      expect(filtered.first.priority, Priority.high);
      expect(filtered.last.priority, Priority.low);
    });
  });
}
