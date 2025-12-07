import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/priority.dart';
import 'package:flutter_tdd/models/todo_filter.dart';
import 'package:flutter_tdd/repositories/todo_repository_interface.dart';
import 'package:flutter_tdd/services/todo_service.dart';
import '../fixtures/todo_fixtures.dart';

import 'todo_service_complex_test.mocks.dart';

@GenerateMocks([TodoRepositoryInterface])
void main() {
  group('TodoService - Complex Scenarios', () {
    late TodoService service;
    late MockTodoRepositoryInterface mockRepository;

    setUp(() {
      mockRepository = MockTodoRepositoryInterface();
      service = TodoService(mockRepository);
    });

    group('Error Handling', () {
      test('should handle repository errors when loading todos', () async {
        // Arrange
        when(
          mockRepository.getAllTodos(),
        ).thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(() => service.loadTodos(), throwsException);
        expect(service.todos, isEmpty);
      });

      test('should handle repository errors when adding todo', () async {
        // Arrange
        when(
          mockRepository.addTodo(any),
        ).thenThrow(Exception('Failed to save todo'));

        // Act & Assert
        expect(() => service.addTodo('Test', 'Description'), throwsException);
      });

      test('should handle repository errors when updating todo', () async {
        // Arrange
        final todo = TodoFixtures.createTodo(id: '1');
        when(mockRepository.getTodoById('1')).thenAnswer((_) async => todo);
        when(
          mockRepository.updateTodo(any),
        ).thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(() => service.toggleTodoCompletion('1'), throwsException);
      });

      test('should handle repository errors when deleting todo', () async {
        // Arrange
        when(
          mockRepository.deleteTodo(any),
        ).thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(() => service.deleteTodo('1'), throwsException);
      });

      test('should handle null todo when toggling completion', () async {
        // Arrange
        when(
          mockRepository.getTodoById('non-existent'),
        ).thenAnswer((_) async => null);

        // Act
        await service.toggleTodoCompletion('non-existent');

        // Assert - Should not throw, but also not update anything
        verify(mockRepository.getTodoById('non-existent')).called(1);
        verifyNever(mockRepository.updateTodo(any));
      });
    });

    group('State Management', () {
      test('should notify listeners when todos are loaded', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(3);
        when(mockRepository.getAllTodos()).thenAnswer((_) async => todos);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => todos);

        bool listenerCalled = false;
        service.addListener(() {
          listenerCalled = true;
        });

        // Act
        await service.loadTodos();

        // Assert
        expect(listenerCalled, true);
        expect(service.todos.length, 3);
      });

      test(
        'should notify listeners multiple times during complex operation',
        () async {
          // Arrange
          final todos = TodoFixtures.createMultipleTodos(2);
          when(mockRepository.getAllTodos()).thenAnswer((_) async => todos);
          when(mockRepository.addTodo(any)).thenAnswer((_) async => {});
          when(
            mockRepository.filterAndSortTodos(any),
          ).thenAnswer((_) async => todos);

          int listenerCallCount = 0;
          service.addListener(() {
            listenerCallCount++;
          });

          // Act
          await service.addTodo('New Todo', 'Description');
          // loadTodos is called internally, which triggers listener

          // Assert
          expect(listenerCallCount, greaterThan(0));
        },
      );

      test('should maintain filter state across operations', () async {
        // Arrange
        final allTodos = TodoFixtures.createMixedTodos();
        final workTodos = allTodos.where((t) => t.category == 'Work').toList();

        when(mockRepository.getAllTodos()).thenAnswer((_) async => allTodos);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => workTodos);

        // Act
        await service.loadTodos();
        final filter = TodoFilter(
          filterBy: TodoFilterBy.byCategory,
          category: 'Work',
        );
        await service.applyFilter(filter);

        // Assert
        expect(service.currentFilter.category, 'Work');
        expect(service.filteredTodos.length, workTodos.length);
      });
    });

    group('Complex Business Logic', () {
      test('should handle adding todo with all optional fields', () async {
        // Arrange
        final dueDate = DateTime.now().add(const Duration(days: 7));
        when(mockRepository.addTodo(any)).thenAnswer((_) async => {});
        when(mockRepository.getAllTodos()).thenAnswer((_) async => []);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => []);

        // Act
        await service.addTodo(
          'Complex Todo',
          'Description',
          priority: Priority.urgent,
          category: 'Work',
          dueDate: dueDate,
        );

        // Assert
        verify(
          mockRepository.addTodo(
            argThat(
              predicate<Todo>(
                (todo) =>
                    todo.title == 'Complex Todo' &&
                    todo.priority == Priority.urgent &&
                    todo.category == 'Work' &&
                    todo.dueDate == dueDate,
              ),
            ),
          ),
        ).called(1);
      });

      test('should trim whitespace from title and description', () async {
        // Arrange
        when(mockRepository.addTodo(any)).thenAnswer((_) async => {});
        when(mockRepository.getAllTodos()).thenAnswer((_) async => []);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => []);

        // Act
        await service.addTodo('  Padded Title  ', '  Padded Description  ');

        // Assert
        verify(
          mockRepository.addTodo(
            argThat(
              predicate<Todo>(
                (todo) =>
                    todo.title == 'Padded Title' &&
                    todo.description == 'Padded Description',
              ),
            ),
          ),
        ).called(1);
      });

      test('should handle search with empty query', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(5);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => todos);

        // Act
        await service.searchTodos('');

        // Assert
        verify(
          mockRepository.filterAndSortTodos(
            argThat(
              predicate<TodoFilter>((filter) => filter.searchQuery == null),
            ),
          ),
        ).called(1);
      });

      test('should combine search with existing filter', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(2);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => todos);

        // Act
        final filter = TodoFilter(
          filterBy: TodoFilterBy.byCategory,
          category: 'Work',
        );
        await service.applyFilter(filter);
        await service.searchTodos('test');

        // Assert
        verify(
          mockRepository.filterAndSortTodos(
            argThat(
              predicate<TodoFilter>(
                (f) => f.category == 'Work' && f.searchQuery == 'test',
              ),
            ),
          ),
        ).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle empty title validation', () async {
        // Act & Assert
        expect(
          () => service.addTodo('', 'Description'),
          throwsA(isA<ArgumentError>()),
        );
        verifyNever(mockRepository.addTodo(any));
      });

      test('should handle whitespace-only title', () async {
        // Act & Assert
        expect(
          () => service.addTodo('   ', 'Description'),
          throwsA(isA<ArgumentError>()),
        );
        verifyNever(mockRepository.addTodo(any));
      });

      test('should handle very long title', () async {
        // Arrange
        final longTitle = 'A' * 1000;
        when(mockRepository.addTodo(any)).thenAnswer((_) async => {});
        when(mockRepository.getAllTodos()).thenAnswer((_) async => []);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => []);

        // Act
        await service.addTodo(longTitle, 'Description');

        // Assert
        verify(
          mockRepository.addTodo(
            argThat(predicate<Todo>((todo) => todo.title == longTitle)),
          ),
        ).called(1);
      });

      test(
        'should handle special characters in title and description',
        () async {
          // Arrange
          const specialTitle = 'Todo with "quotes" & <tags> & symbols!';
          const specialDesc = 'Description with\nnewlines\tand\ttabs';
          when(mockRepository.addTodo(any)).thenAnswer((_) async => {});
          when(mockRepository.getAllTodos()).thenAnswer((_) async => []);
          when(
            mockRepository.filterAndSortTodos(any),
          ).thenAnswer((_) async => []);

          // Act
          await service.addTodo(specialTitle, specialDesc);

          // Assert
          verify(
            mockRepository.addTodo(
              argThat(
                predicate<Todo>(
                  (todo) =>
                      todo.title == specialTitle &&
                      todo.description == specialDesc,
                ),
              ),
            ),
          ).called(1);
        },
      );

      test('should handle null optional parameters', () async {
        // Arrange
        when(mockRepository.addTodo(any)).thenAnswer((_) async => {});
        when(mockRepository.getAllTodos()).thenAnswer((_) async => []);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => []);

        // Act
        await service.addTodo('Title', 'Description');

        // Assert
        verify(
          mockRepository.addTodo(
            argThat(
              predicate<Todo>(
                (todo) =>
                    todo.priority == Priority.medium &&
                    todo.category == '' &&
                    todo.dueDate == null,
              ),
            ),
          ),
        ).called(1);
      });
    });

    group('Statistics and Aggregations', () {
      test('should calculate statistics correctly with mixed todos', () async {
        // Arrange
        final todos = TodoFixtures.createMixedTodos();
        when(mockRepository.getAllTodos()).thenAnswer((_) async => todos);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => todos);

        // Act
        await service.loadTodos();

        // Assert
        final completedCount = service.getCompletedCount();
        final pendingCount = service.getPendingCount();
        final overdueCount = service.getOverdueCount();
        final dueSoonCount = service.getDueSoonCount();

        expect(completedCount, greaterThan(0));
        expect(pendingCount, greaterThan(0));
        expect(overdueCount, greaterThan(0));
        expect(dueSoonCount, greaterThan(0));
        expect(completedCount + pendingCount, todos.length);
      });

      test('should handle statistics with empty todo list', () async {
        // Arrange
        when(mockRepository.getAllTodos()).thenAnswer((_) async => []);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => []);

        // Act
        await service.loadTodos();

        // Assert
        expect(service.getCompletedCount(), 0);
        expect(service.getPendingCount(), 0);
        expect(service.getOverdueCount(), 0);
        expect(service.getDueSoonCount(), 0);
      });
    });

    group('Filter Combinations', () {
      test('should apply multiple filter criteria', () async {
        // Arrange
        final filteredTodos = TodoFixtures.createMultipleTodos(2);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => filteredTodos);

        // Act
        final filter = TodoFilter(
          filterBy: TodoFilterBy.byCategory,
          category: 'Work',
          sortBy: TodoSortBy.priority,
          sortAscending: false,
        );
        await service.applyFilter(filter);

        // Assert
        verify(
          mockRepository.filterAndSortTodos(
            argThat(
              predicate<TodoFilter>(
                (f) =>
                    f.filterBy == TodoFilterBy.byCategory &&
                    f.category == 'Work' &&
                    f.sortBy == TodoSortBy.priority &&
                    f.sortAscending == false,
              ),
            ),
          ),
        ).called(1);
      });

      test('should clear filter and reset to all todos', () async {
        // Arrange
        final allTodos = TodoFixtures.createMultipleTodos(10);
        when(
          mockRepository.filterAndSortTodos(any),
        ).thenAnswer((_) async => allTodos);

        // Act
        await service.clearFilter();

        // Assert
        verify(
          mockRepository.filterAndSortTodos(
            argThat(
              predicate<TodoFilter>((f) => f.filterBy == TodoFilterBy.all),
            ),
          ),
        ).called(1);
        expect(service.currentFilter.filterBy, TodoFilterBy.all);
      });
    });
  });
}
