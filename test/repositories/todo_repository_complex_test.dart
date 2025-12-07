import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/priority.dart';
import 'package:flutter_tdd/models/todo_filter.dart';
import 'package:flutter_tdd/repositories/todo_repository.dart';
import '../fixtures/todo_fixtures.dart';

void main() {
  group('TodoRepository - Complex Scenarios', () {
    late TodoRepository repository;

    setUp(() {
      repository = TodoRepository();
    });

    group('Concurrency and Race Conditions', () {
      test('should handle concurrent add operations', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(100);

        // Act - Add todos concurrently
        await Future.wait(todos.map((todo) => repository.addTodo(todo)));

        // Assert
        final allTodos = await repository.getAllTodos();
        expect(allTodos.length, 100);
        expect(allTodos.toSet().length, 100); // All unique
      });

      test('should handle concurrent update operations', () async {
        // Arrange
        final todo = TodoFixtures.createTodo(id: '1', title: 'Original');
        await repository.addTodo(todo);

        // Act - Update concurrently
        await Future.wait([
          repository.updateTodo(todo.copyWith(title: 'Update 1')),
          repository.updateTodo(todo.copyWith(title: 'Update 2')),
          repository.updateTodo(todo.copyWith(title: 'Update 3')),
        ]);

        // Assert - Last update should win (or one of them)
        final updated = await repository.getTodoById('1');
        expect(updated, isNotNull);
        expect(['Update 1', 'Update 2', 'Update 3'], contains(updated!.title));
      });

      test('should handle concurrent delete operations', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(10);
        for (final todo in todos) {
          await repository.addTodo(todo);
        }

        // Act - Delete concurrently
        await Future.wait([
          repository.deleteTodo('todo-0'),
          repository.deleteTodo('todo-1'),
          repository.deleteTodo('todo-2'),
        ]);

        // Assert
        final remaining = await repository.getAllTodos();
        expect(remaining.length, 7);
        expect(remaining.any((t) => t.id == 'todo-0'), false);
        expect(remaining.any((t) => t.id == 'todo-1'), false);
        expect(remaining.any((t) => t.id == 'todo-2'), false);
      });

      test('should handle mixed concurrent operations', () async {
        // Arrange
        final initialTodos = TodoFixtures.createMultipleTodos(5);
        for (final todo in initialTodos) {
          await repository.addTodo(todo);
        }

        // Act - Mix of add, update, delete concurrently
        await Future.wait([
          repository.addTodo(TodoFixtures.createTodo(id: 'new-1')),
          repository.updateTodo(
            (await repository.getTodoById(
              'todo-0',
            ))!.copyWith(title: 'Updated'),
          ),
          repository.deleteTodo('todo-1'),
          repository.addTodo(TodoFixtures.createTodo(id: 'new-2')),
        ]);

        // Assert
        final allTodos = await repository.getAllTodos();
        expect(allTodos.length, 6); // 5 - 1 deleted + 2 added
        expect(allTodos.any((t) => t.id == 'new-1'), true);
        expect(allTodos.any((t) => t.id == 'new-2'), true);
        expect(allTodos.any((t) => t.id == 'todo-1'), false);
      });
    });

    group('Large Dataset Operations', () {
      test('should handle filtering large dataset efficiently', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(1000);
        for (final todo in todos) {
          await repository.addTodo(todo);
        }

        // Act
        final startTime = DateTime.now();
        final filtered = await repository.filterAndSortTodos(
          const TodoFilter(filterBy: TodoFilterBy.pending),
        );
        final duration = DateTime.now().difference(startTime);

        // Assert
        expect(filtered.length, 1000); // All are pending by default
        expect(duration.inMilliseconds, lessThan(1000)); // Should be fast
      });

      test('should handle searching large dataset', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(500);
        for (final todo in todos) {
          await repository.addTodo(todo);
        }
        // Add some with specific search terms
        await repository.addTodo(
          TodoFixtures.createTodo(id: 'search-1', title: 'FindMe'),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(id: 'search-2', description: 'FindMe too'),
        );

        // Act
        final results = await repository.searchTodos('FindMe');

        // Assert
        expect(results.length, 2);
        expect(results.any((t) => t.id == 'search-1'), true);
        expect(results.any((t) => t.id == 'search-2'), true);
      });

      test('should handle sorting large dataset', () async {
        // Arrange
        final todos = List.generate(100, (i) {
          return TodoFixtures.createTodo(
            id: 'todo-$i',
            priority: Priority.values[i % Priority.values.length],
          );
        });
        for (final todo in todos) {
          await repository.addTodo(todo);
        }

        // Act
        final sorted = await repository.filterAndSortTodos(
          TodoFilter(sortBy: TodoSortBy.priority, sortAscending: false),
        );

        // Assert
        expect(sorted.length, 100);
        // Check that sorting is correct (highest priority first)
        for (int i = 0; i < sorted.length - 1; i++) {
          expect(
            sorted[i].priority.value,
            greaterThanOrEqualTo(sorted[i + 1].priority.value),
          );
        }
      });
    });

    group('Complex Filtering Scenarios', () {
      test('should handle multiple filter criteria combined', () async {
        // Arrange
        await repository.addTodo(
          TodoFixtures.createWorkTodo(
            id: '1',
            title: 'Urgent Work',
            priority: Priority.urgent,
          ),
        );
        await repository.addTodo(
          TodoFixtures.createWorkTodo(
            id: '2',
            title: 'Low Work',
            priority: Priority.low,
          ),
        );
        await repository.addTodo(
          TodoFixtures.createPersonalTodo(
            id: '3',
            title: 'Urgent Personal',
            priority: Priority.urgent,
          ),
        );

        // Act - Filter by category and priority
        final workTodos = await repository.getTodosByCategory('Work');
        final urgentWorkTodos = workTodos
            .where((t) => t.priority == Priority.urgent)
            .toList();

        // Assert
        expect(workTodos.length, 2);
        expect(urgentWorkTodos.length, 1);
        expect(urgentWorkTodos.first.id, '1');
      });

      test('should handle filter with search query', () async {
        // Arrange
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '1',
            title: 'Buy groceries',
            category: 'Shopping',
          ),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '2',
            title: 'Buy milk',
            category: 'Shopping',
          ),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '3',
            title: 'Call dentist',
            category: 'Health',
          ),
        );

        // Act
        final filter = TodoFilter(
          filterBy: TodoFilterBy.byCategory,
          category: 'Shopping',
          searchQuery: 'groceries',
        );
        final results = await repository.filterAndSortTodos(filter);

        // Assert
        expect(results.length, 1);
        expect(results.first.id, '1');
      });

      test('should handle filter with multiple sort criteria', () async {
        // Arrange
        final now = DateTime.now();
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '1',
            title: 'A Task',
            priority: Priority.high,
            dueDate: now.add(const Duration(days: 2)),
          ),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '2',
            title: 'B Task',
            priority: Priority.high,
            dueDate: now.add(const Duration(days: 1)),
          ),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '3',
            title: 'C Task',
            priority: Priority.low,
            dueDate: now.add(const Duration(days: 1)),
          ),
        );

        // Act - Sort by priority first, then by due date
        final filter = TodoFilter(
          filterBy: TodoFilterBy.byPriority,
          priority: Priority.high,
          sortBy: TodoSortBy.dueDate,
          sortAscending: true,
        );
        final results = await repository.filterAndSortTodos(filter);

        // Assert
        expect(results.length, 2);
        expect(results.first.id, '2'); // Earlier due date
        expect(results.last.id, '1');
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      test('should handle empty repository operations', () async {
        // Act & Assert
        expect(await repository.getAllTodos(), isEmpty);
        expect(await repository.getTodoById('non-existent'), isNull);
        expect(await repository.getCompletedTodos(), isEmpty);
        expect(await repository.getPendingTodos(), isEmpty);
        expect(await repository.searchTodos('anything'), isEmpty);
        expect(await repository.getAllCategories(), isEmpty);
      });

      test('should handle updating non-existent todo', () async {
        // Arrange
        final todo = TodoFixtures.createTodo(id: 'non-existent');

        // Act
        await repository.updateTodo(todo);

        // Assert - Should not throw, but also not add the todo
        expect(await repository.getTodoById('non-existent'), isNull);
      });

      test('should handle deleting non-existent todo', () async {
        // Act - Should not throw
        await repository.deleteTodo('non-existent');

        // Assert
        expect(await repository.getAllTodos(), isEmpty);
      });

      test('should handle todos with same title but different IDs', () async {
        // Arrange
        final todo1 = TodoFixtures.createTodo(id: '1', title: 'Same Title');
        final todo2 = TodoFixtures.createTodo(id: '2', title: 'Same Title');

        // Act
        await repository.addTodo(todo1);
        await repository.addTodo(todo2);

        // Assert
        final todos = await repository.getAllTodos();
        expect(todos.length, 2);
        expect(todos.where((t) => t.title == 'Same Title').length, 2);
      });

      test('should handle todos with empty category', () async {
        // Arrange
        await repository.addTodo(
          TodoFixtures.createTodo(id: '1', category: ''),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(id: '2', category: 'Work'),
        );

        // Act
        final categories = await repository.getAllCategories();

        // Assert
        expect(categories.length, 1);
        expect(categories.contains('Work'), true);
        expect(categories.contains(''), false);
      });

      test('should handle case-insensitive search', () async {
        // Arrange
        await repository.addTodo(
          TodoFixtures.createTodo(id: '1', title: 'UPPERCASE TITLE'),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(id: '2', title: 'lowercase title'),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(id: '3', title: 'MiXeD CaSe'),
        );

        // Act
        final results1 = await repository.searchTodos('uppercase');
        final results2 = await repository.searchTodos('LOWERCASE');
        final results3 = await repository.searchTodos('mixed');

        // Assert
        expect(results1.length, 1);
        expect(results2.length, 1);
        expect(results3.length, 1);
      });

      test('should handle special characters in search', () async {
        // Arrange
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '1',
            title: 'Task with "quotes"',
            description: 'Description with <tags>',
          ),
        );

        // Act
        final results1 = await repository.searchTodos('quotes');
        final results2 = await repository.searchTodos('tags');

        // Assert
        expect(results1.length, 1);
        expect(results2.length, 1);
      });
    });

    group('Data Integrity', () {
      test(
        'should maintain data integrity after multiple operations',
        () async {
          // Arrange
          final todos = TodoFixtures.createMultipleTodos(10);
          for (final todo in todos) {
            await repository.addTodo(todo);
          }

          // Act - Complex sequence of operations
          await repository.updateTodo(todos[0].copyWith(title: 'Updated'));
          await repository.deleteTodo(todos[1].id);
          await repository.addTodo(TodoFixtures.createTodo(id: 'new-1'));
          await repository.updateTodo(todos[2].copyWith(isCompleted: true));
          await repository.deleteTodo(todos[3].id);

          // Assert
          final allTodos = await repository.getAllTodos();
          expect(allTodos.length, 9); // 10 - 2 deleted + 1 added
          expect(
            allTodos.any((t) => t.id == todos[0].id && t.title == 'Updated'),
            true,
          );
          expect(allTodos.any((t) => t.id == todos[1].id), false);
          expect(allTodos.any((t) => t.id == 'new-1'), true);
          expect(
            allTodos.any((t) => t.id == todos[2].id && t.isCompleted),
            true,
          );
          expect(allTodos.any((t) => t.id == todos[3].id), false);
        },
      );

      test('should return immutable lists', () async {
        // Arrange
        await repository.addTodo(TodoFixtures.createTodo(id: '1'));

        // Act
        final todos = await repository.getAllTodos();

        // Assert
        expect(
          () => todos.add(TodoFixtures.createTodo(id: '2')),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('should handle todos with null due dates in sorting', () async {
        // Arrange
        final now = DateTime.now();
        await repository.addTodo(
          TodoFixtures.createTodo(id: '1', dueDate: null),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(
            id: '2',
            dueDate: now.add(const Duration(days: 1)),
          ),
        );
        await repository.addTodo(
          TodoFixtures.createTodo(id: '3', dueDate: null),
        );

        // Act
        final sorted = await repository.filterAndSortTodos(
          TodoFilter(sortBy: TodoSortBy.dueDate, sortAscending: true),
        );

        // Assert
        expect(sorted.length, 3);
        // Todos with due dates should come first
        expect(sorted.first.id, '2');
        // Todos with null due dates should be at the end
        expect(['1', '3'], contains(sorted.last.id));
      });
    });
  });
}
