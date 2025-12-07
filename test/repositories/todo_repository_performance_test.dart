import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/todo_filter.dart';
import 'package:flutter_tdd/repositories/todo_repository.dart';
import '../fixtures/todo_fixtures.dart';

void main() {
  group('TodoRepository - Performance Tests', () {
    late TodoRepository repository;

    setUp(() {
      repository = TodoRepository();
    });

    test('should handle adding 10,000 todos efficiently', () async {
      // Arrange
      final todos = TodoFixtures.createMultipleTodos(10000);

      // Act
      final startTime = DateTime.now();
      for (final todo in todos) {
        await repository.addTodo(todo);
      }
      final duration = DateTime.now().difference(startTime);

      // Assert
      final allTodos = await repository.getAllTodos();
      expect(allTodos.length, 10000);
      expect(duration.inSeconds, lessThan(5)); // Should complete in < 5 seconds
    });

    test('should handle filtering 10,000 todos efficiently', () async {
      // Arrange
      final todos = TodoFixtures.createMultipleTodos(10000);
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
      expect(filtered.length, 10000);
      expect(duration.inMilliseconds, lessThan(500)); // Should be fast
    });

    test('should handle searching 10,000 todos efficiently', () async {
      // Arrange
      final todos = TodoFixtures.createMultipleTodos(10000);
      for (final todo in todos) {
        await repository.addTodo(todo);
      }
      // Add a few with specific search term
      await repository.addTodo(
        TodoFixtures.createTodo(id: 'search-1', title: 'UniqueSearchTerm'),
      );
      await repository.addTodo(
        TodoFixtures.createTodo(
          id: 'search-2',
          description: 'UniqueSearchTerm',
        ),
      );

      // Act
      final startTime = DateTime.now();
      final results = await repository.searchTodos('UniqueSearchTerm');
      final duration = DateTime.now().difference(startTime);

      // Assert
      expect(results.length, 2);
      expect(duration.inMilliseconds, lessThan(500));
    });

    test('should handle sorting 10,000 todos efficiently', () async {
      // Arrange
      final todos = List.generate(10000, (i) {
        return TodoFixtures.createTodo(
          id: 'todo-$i',
          title: 'Todo ${10000 - i}', // Reverse order
        );
      });
      for (final todo in todos) {
        await repository.addTodo(todo);
      }

      // Act
      final startTime = DateTime.now();
      final sorted = await repository.filterAndSortTodos(
        TodoFilter(sortBy: TodoSortBy.title, sortAscending: true),
      );
      final duration = DateTime.now().difference(startTime);

      // Assert
      expect(sorted.length, 10000);
      expect(duration.inMilliseconds, lessThan(1000));
      // Verify sorting is correct
      for (int i = 0; i < sorted.length - 1; i++) {
        expect(
          sorted[i].title.compareTo(sorted[i + 1].title),
          lessThanOrEqualTo(0),
        );
      }
    });

    test('should handle multiple concurrent filter operations', () async {
      // Arrange
      final todos = TodoFixtures.createMultipleTodos(5000);
      for (final todo in todos) {
        await repository.addTodo(todo);
      }

      // Act
      final startTime = DateTime.now();
      await Future.wait([
        repository.filterAndSortTodos(
          const TodoFilter(filterBy: TodoFilterBy.pending),
        ),
        repository.filterAndSortTodos(
          const TodoFilter(filterBy: TodoFilterBy.completed),
        ),
        repository.filterAndSortTodos(
          const TodoFilter(filterBy: TodoFilterBy.all),
        ),
        repository.searchTodos('Todo'),
        repository.getAllCategories(),
      ]);
      final duration = DateTime.now().difference(startTime);

      // Assert
      expect(duration.inMilliseconds, lessThan(1000));
    });

    test('should handle bulk operations efficiently', () async {
      // Arrange
      final todos = TodoFixtures.createMultipleTodos(5000);

      // Act - Bulk add
      final addStartTime = DateTime.now();
      for (final todo in todos) {
        await repository.addTodo(todo);
      }
      final addDuration = DateTime.now().difference(addStartTime);

      // Bulk update
      final updateStartTime = DateTime.now();
      for (int i = 0; i < 1000; i++) {
        final todo = await repository.getTodoById('todo-$i');
        if (todo != null) {
          await repository.updateTodo(todo.copyWith(isCompleted: true));
        }
      }
      final updateDuration = DateTime.now().difference(updateStartTime);

      // Bulk delete
      final deleteStartTime = DateTime.now();
      for (int i = 0; i < 1000; i++) {
        await repository.deleteTodo('todo-${i + 1000}');
      }
      final deleteDuration = DateTime.now().difference(deleteStartTime);

      // Assert
      final remaining = await repository.getAllTodos();
      expect(remaining.length, 4000);
      expect(addDuration.inSeconds, lessThan(3));
      expect(updateDuration.inSeconds, lessThan(3));
      expect(deleteDuration.inSeconds, lessThan(2));
    });

    test('should maintain performance with repeated operations', () async {
      // Arrange
      final todos = TodoFixtures.createMultipleTodos(1000);
      for (final todo in todos) {
        await repository.addTodo(todo);
      }

      // Act - Perform same operation multiple times
      final durations = <Duration>[];
      for (int i = 0; i < 10; i++) {
        final startTime = DateTime.now();
        await repository.filterAndSortTodos(
          const TodoFilter(filterBy: TodoFilterBy.all),
        );
        durations.add(DateTime.now().difference(startTime));
      }

      // Assert - Performance should be consistent
      final avgDuration =
          durations.map((d) => d.inMilliseconds).reduce((a, b) => a + b) /
          durations.length;
      expect(avgDuration, lessThan(100)); // Average should be fast

      // All operations should complete in reasonable time
      for (final duration in durations) {
        expect(duration.inMilliseconds, lessThan(200));
      }
    });
  });
}
