import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/priority.dart';
import 'package:flutter_tdd/models/todo_filter.dart';
import 'package:flutter_tdd/repositories/todo_repository.dart';
import 'package:flutter_tdd/services/todo_service.dart';

void main() {
  group('TodoService', () {
    late TodoService service;
    late TodoRepository repository;

    setUp(() {
      repository = TodoRepository();
      service = TodoService(repository);
    });

    test('should initialize with empty todos', () {
      // Assert
      expect(service.todos, isEmpty);
    });

    test('should load todos from repository', () async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );
      await repository.addTodo(todo);

      // Act
      await service.loadTodos();

      // Assert
      expect(service.todos.length, 1);
      expect(service.todos.first.title, 'Test Todo');
    });

    test('should add a todo', () async {
      // Act
      await service.addTodo('New Todo', 'New Description');
      await service.loadTodos();

      // Assert
      expect(service.todos.length, 1);
      expect(service.todos.first.title, 'New Todo');
      expect(service.todos.first.description, 'New Description');
    });

    test('should throw error when adding todo with empty title', () async {
      // Act & Assert
      expect(
        () => service.addTodo('', 'Description'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should toggle todo completion', () async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );
      await repository.addTodo(todo);
      await service.loadTodos();

      // Act
      await service.toggleTodoCompletion('1');
      await service.loadTodos();

      // Assert
      expect(service.todos.first.isCompleted, true);
    });

    test('should delete a todo', () async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );
      await repository.addTodo(todo);
      await service.loadTodos();

      // Act
      await service.deleteTodo('1');
      await service.loadTodos();

      // Assert
      expect(service.todos, isEmpty);
    });

    test('should get completed todos count', () async {
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
      await service.loadTodos();

      // Act
      final count = service.getCompletedCount();

      // Assert
      expect(count, 1);
    });

    test('should get pending todos count', () async {
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
      await service.loadTodos();

      // Act
      final count = service.getPendingCount();

      // Assert
      expect(count, 1);
    });

    test('should add todo with priority, category, and dueDate', () async {
      // Act
      final dueDate = DateTime.now().add(const Duration(days: 7));
      await service.addTodo(
        'New Todo',
        'Description',
        priority: Priority.high,
        category: 'Work',
        dueDate: dueDate,
      );
      await service.loadTodos();

      // Assert
      expect(service.todos.length, 1);
      expect(service.todos.first.priority, Priority.high);
      expect(service.todos.first.category, 'Work');
      expect(service.todos.first.dueDate, dueDate);
    });

    test('should filter todos', () async {
      // Arrange
      await service.addTodo('Work Task', 'Test', category: 'Work');
      await service.addTodo('Personal Task', 'Test', category: 'Personal');
      await service.addTodo('Another Work', 'Test', category: 'Work');
      await service.loadTodos();

      // Act
      final filter = TodoFilter(
        filterBy: TodoFilterBy.byCategory,
        category: 'Work',
      );
      await service.applyFilter(filter);

      // Assert
      expect(service.filteredTodos.length, 2);
      expect(service.filteredTodos.every((t) => t.category == 'Work'), true);
    });

    test('should search todos', () async {
      // Arrange
      await service.addTodo('Buy grocery items', 'Milk and eggs');
      await service.addTodo('Call dentist', 'Schedule appointment');
      await service.addTodo('Grocery shopping', 'Vegetables');
      await service.loadTodos();

      // Act
      await service.searchTodos('grocery');

      // Assert
      expect(service.filteredTodos.length, 2);
    });

    test('should get all categories', () async {
      // Arrange
      await service.addTodo('Task 1', 'Test', category: 'Work');
      await service.addTodo('Task 2', 'Test', category: 'Personal');
      await service.addTodo('Task 3', 'Test', category: 'Work');
      await service.loadTodos();

      // Act
      final categories = await service.getAllCategories();

      // Assert
      expect(categories.length, 2);
      expect(categories.contains('Work'), true);
      expect(categories.contains('Personal'), true);
    });

    test('should get overdue count', () async {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      await service.addTodo('Overdue 1', 'Test', dueDate: pastDate);
      await service.addTodo('Overdue 2', 'Test', dueDate: pastDate);
      await service.addTodo(
        'Not Overdue',
        'Test',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      await service.loadTodos();

      // Act
      final count = service.getOverdueCount();

      // Assert
      expect(count, 2);
    });

    test('should get due soon count', () async {
      // Arrange
      final dueSoon = DateTime.now().add(const Duration(hours: 12));
      await service.addTodo('Due Soon 1', 'Test', dueDate: dueSoon);
      await service.addTodo('Due Soon 2', 'Test', dueDate: dueSoon);
      await service.addTodo(
        'Not Due Soon',
        'Test',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      );
      await service.loadTodos();

      // Act
      final count = service.getDueSoonCount();

      // Assert
      expect(count, 2);
    });

    test('should clear filter', () async {
      // Arrange
      await service.addTodo('Task 1', 'Test', category: 'Work');
      await service.addTodo('Task 2', 'Test', category: 'Personal');
      await service.loadTodos();

      final filter = TodoFilter(
        filterBy: TodoFilterBy.byCategory,
        category: 'Work',
      );
      await service.applyFilter(filter);

      // Act
      await service.clearFilter();

      // Assert
      expect(service.filteredTodos.length, 2);
    });

    test('should sort todos by priority', () async {
      // Arrange
      await service.addTodo('Low', 'Test', priority: Priority.low);
      await service.addTodo('High', 'Test', priority: Priority.high);
      await service.addTodo('Medium', 'Test', priority: Priority.medium);
      await service.loadTodos();

      // Act
      final filter = TodoFilter(
        sortBy: TodoSortBy.priority,
        sortAscending: false,
      );
      await service.applyFilter(filter);

      // Assert
      expect(service.filteredTodos.first.priority, Priority.high);
      expect(service.filteredTodos.last.priority, Priority.low);
    });
  });
}
