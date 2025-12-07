import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/models/priority.dart';
import 'package:flutter_tdd/models/todo_filter.dart';
import 'package:flutter_tdd/repositories/todo_repository.dart';
import 'package:flutter_tdd/services/todo_service.dart';
import '../fixtures/todo_fixtures.dart';

void main() {
  group('Complex Integration Tests', () {
    late TodoRepository repository;
    late TodoService service;

    setUp(() {
      repository = TodoRepository();
      service = TodoService(repository);
    });

    group('End-to-End Workflows', () {
      test('should complete full todo lifecycle', () async {
        // Arrange & Act - Create
        await service.addTodo(
          'Complete Project',
          'Finish the Flutter TDD app',
          priority: Priority.high,
          category: 'Work',
          dueDate: DateTime.now().add(const Duration(days: 7)),
        );
        await service.loadTodos();

        // Assert - Verify creation
        expect(service.todos.length, 1);
        final createdTodo = service.todos.first;
        expect(createdTodo.title, 'Complete Project');
        expect(createdTodo.priority, Priority.high);
        expect(createdTodo.category, 'Work');

        // Act - Update (toggle completion)
        await service.toggleTodoCompletion(createdTodo.id);
        await service.loadTodos();

        // Assert - Verify update
        expect(service.todos.first.isCompleted, true);
        expect(service.getCompletedCount(), 1);
        expect(service.getPendingCount(), 0);

        // Act - Delete
        await service.deleteTodo(createdTodo.id);
        await service.loadTodos();

        // Assert - Verify deletion
        expect(service.todos, isEmpty);
      });

      test('should handle complex filtering and searching workflow', () async {
        // Arrange - Create diverse todos
        await service.addTodo('Work Task 1', 'Description', category: 'Work');
        await service.addTodo('Work Task 2', 'Description', category: 'Work');
        await service.addTodo(
          'Personal Task',
          'Description',
          category: 'Personal',
        );
        await service.addTodo('Buy groceries', 'Milk and eggs');
        await service.loadTodos();

        // Act - Apply category filter
        final categoryFilter = TodoFilter(
          filterBy: TodoFilterBy.byCategory,
          category: 'Work',
        );
        await service.applyFilter(categoryFilter);

        // Assert
        expect(service.filteredTodos.length, 2);
        expect(service.filteredTodos.every((t) => t.category == 'Work'), true);

        // Act - Search within filtered results
        await service.searchTodos('Task');

        // Assert
        expect(service.filteredTodos.length, 2);
        expect(
          service.filteredTodos.every((t) => t.title.contains('Task')),
          true,
        );

        // Act - Clear filter
        await service.clearFilter();

        // Assert
        expect(service.filteredTodos.length, 4);
      });

      test('should handle priority-based workflow', () async {
        // Arrange
        await service.addTodo('Low Priority', 'Task', priority: Priority.low);
        await service.addTodo(
          'Medium Priority',
          'Task',
          priority: Priority.medium,
        );
        await service.addTodo('High Priority', 'Task', priority: Priority.high);
        await service.addTodo(
          'Urgent Priority',
          'Task',
          priority: Priority.urgent,
        );
        await service.loadTodos();

        // Act - Filter by priority and sort
        final filter = TodoFilter(
          filterBy: TodoFilterBy.byPriority,
          priority: Priority.high,
          sortBy: TodoSortBy.priority,
          sortAscending: false,
        );
        await service.applyFilter(filter);

        // Assert
        expect(service.filteredTodos.length, 1);
        expect(service.filteredTodos.first.priority, Priority.high);

        // Act - Get statistics
        final overdueCount = service.getOverdueCount();
        final dueSoonCount = service.getDueSoonCount();

        // Assert
        expect(overdueCount, 0);
        expect(dueSoonCount, 0);
      });

      test('should handle due date workflow', () async {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final soonDate = DateTime.now().add(const Duration(hours: 12));
        final futureDate = DateTime.now().add(const Duration(days: 7));

        await service.addTodo('Overdue Task', 'Description', dueDate: pastDate);
        await service.addTodo(
          'Due Soon Task',
          'Description',
          dueDate: soonDate,
        );
        await service.addTodo(
          'Future Task',
          'Description',
          dueDate: futureDate,
        );
        await service.loadTodos();

        // Act - Filter overdue
        final overdueFilter = TodoFilter(filterBy: TodoFilterBy.overdue);
        await service.applyFilter(overdueFilter);

        // Assert
        expect(service.filteredTodos.length, 1);
        expect(service.filteredTodos.first.title, 'Overdue Task');
        expect(service.getOverdueCount(), 1);

        // Act - Filter due soon
        final dueSoonFilter = TodoFilter(filterBy: TodoFilterBy.dueSoon);
        await service.applyFilter(dueSoonFilter);

        // Assert
        expect(service.filteredTodos.length, 1);
        expect(service.filteredTodos.first.title, 'Due Soon Task');
        expect(service.getDueSoonCount(), 1);
      });
    });

    group('Multi-Step Operations', () {
      test('should handle batch operations workflow', () async {
        // Arrange
        final todos = TodoFixtures.createMultipleTodos(10);
        for (final todo in todos) {
          await repository.addTodo(todo);
        }
        await service.loadTodos();

        // Act - Complete multiple todos
        for (int i = 0; i < 5; i++) {
          await service.toggleTodoCompletion('todo-$i');
        }
        await service.loadTodos();

        // Assert
        expect(service.getCompletedCount(), 5);
        expect(service.getPendingCount(), 5);

        // Act - Delete completed todos
        final completedTodos = service.todos
            .where((t) => t.isCompleted)
            .toList();
        for (final todo in completedTodos) {
          await service.deleteTodo(todo.id);
        }
        await service.loadTodos();

        // Assert
        expect(service.todos.length, 5);
        expect(service.getCompletedCount(), 0);
        expect(service.getPendingCount(), 5);
      });

      test('should handle complex filter chain', () async {
        // Arrange
        await service.addTodo(
          'Urgent Work Task',
          'Description',
          priority: Priority.urgent,
          category: 'Work',
        );
        await service.addTodo(
          'High Work Task',
          'Description',
          priority: Priority.high,
          category: 'Work',
        );
        await service.addTodo(
          'Urgent Personal',
          'Description',
          priority: Priority.urgent,
          category: 'Personal',
        );
        await service.loadTodos();

        // Act - Chain filters
        // Step 1: Filter by category
        await service.applyFilter(
          TodoFilter(filterBy: TodoFilterBy.byCategory, category: 'Work'),
        );
        expect(service.filteredTodos.length, 2);

        // Step 2: Add priority filter (simulated by repository filter)
        final combinedFilter = TodoFilter(
          filterBy: TodoFilterBy.byCategory,
          category: 'Work',
          sortBy: TodoSortBy.priority,
          sortAscending: false,
        );
        await service.applyFilter(combinedFilter);

        // Assert
        expect(service.filteredTodos.length, 2);
        expect(service.filteredTodos.first.priority, Priority.urgent);
      });

      test('should handle search and filter combination', () async {
        // Arrange
        await service.addTodo(
          'Buy groceries',
          'Milk and eggs',
          category: 'Shopping',
        );
        await service.addTodo('Buy milk', 'From store', category: 'Shopping');
        await service.addTodo(
          'Call dentist',
          'Schedule appointment',
          category: 'Health',
        );
        await service.loadTodos();

        // Act - Filter then search
        await service.applyFilter(
          TodoFilter(filterBy: TodoFilterBy.byCategory, category: 'Shopping'),
        );
        await service.searchTodos('groceries');

        // Assert
        expect(service.filteredTodos.length, 1);
        expect(service.filteredTodos.first.title, 'Buy groceries');
      });
    });

    group('State Consistency', () {
      test('should maintain consistent state across operations', () async {
        // Arrange
        await service.addTodo('Task 1', 'Description');
        await service.addTodo('Task 2', 'Description');
        await service.loadTodos();

        final initialCount = service.todos.length;

        // Act - Perform multiple operations
        await service.toggleTodoCompletion(service.todos.first.id);
        await service.loadTodos();

        // Assert - State should be consistent
        expect(service.todos.length, initialCount);
        expect(
          service.getCompletedCount() + service.getPendingCount(),
          initialCount,
        );

        // Act - Delete one
        await service.deleteTodo(service.todos.first.id);
        await service.loadTodos();

        // Assert
        expect(service.todos.length, initialCount - 1);
        expect(
          service.getCompletedCount() + service.getPendingCount(),
          initialCount - 1,
        );
      });

      test('should sync repository and service state', () async {
        // Arrange
        await service.addTodo('Service Task', 'Description');
        await service.loadTodos();

        // Act - Add directly to repository
        await repository.addTodo(
          TodoFixtures.createTodo(id: 'repo-task', title: 'Repo Task'),
        );

        // Act - Reload service
        await service.loadTodos();

        // Assert - Service should see repository changes
        expect(service.todos.length, 2);
        expect(service.todos.any((t) => t.id == 'repo-task'), true);
      });
    });

    group('Error Recovery', () {
      test('should recover from invalid operations gracefully', () async {
        // Arrange
        await service.addTodo('Valid Task', 'Description');
        await service.loadTodos();

        // Act - Try to toggle non-existent todo
        await service.toggleTodoCompletion('non-existent');
        await service.loadTodos();

        // Assert - Should not affect existing todos
        expect(service.todos.length, 1);
        expect(service.todos.first.title, 'Valid Task');

        // Act - Try to delete non-existent todo
        await service.deleteTodo('non-existent');
        await service.loadTodos();

        // Assert - Should not affect existing todos
        expect(service.todos.length, 1);
      });

      test('should handle empty operations gracefully', () async {
        // Act - Operations on empty service
        await service.loadTodos();
        await service.clearFilter();
        await service.searchTodos('');

        // Assert - Should not throw
        expect(service.todos, isEmpty);
        expect(service.filteredTodos, isEmpty);
        expect(service.getCompletedCount(), 0);
        expect(service.getPendingCount(), 0);
      });
    });

    group('Real-World Scenarios', () {
      test('should handle daily todo management workflow', () async {
        // Morning: Add todos for the day
        await service.addTodo(
          'Morning Exercise',
          '30 min workout',
          priority: Priority.high,
          category: 'Health',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
        );
        await service.addTodo(
          'Team Meeting',
          'Discuss project progress',
          priority: Priority.urgent,
          category: 'Work',
          dueDate: DateTime.now().add(const Duration(hours: 4)),
        );
        await service.addTodo(
          'Buy groceries',
          'Milk, eggs, bread',
          priority: Priority.medium,
          category: 'Shopping',
        );
        await service.loadTodos();

        // Check what's due soon
        expect(service.getDueSoonCount(), greaterThan(0));

        // Complete morning exercise
        final exerciseTodo = service.todos.firstWhere(
          (t) => t.title == 'Morning Exercise',
        );
        await service.toggleTodoCompletion(exerciseTodo.id);
        await service.loadTodos();

        expect(service.getCompletedCount(), 1);

        // Filter work tasks
        await service.applyFilter(
          TodoFilter(filterBy: TodoFilterBy.byCategory, category: 'Work'),
        );
        expect(service.filteredTodos.length, 1);
        expect(service.filteredTodos.first.title, 'Team Meeting');
      });

      test('should handle project management workflow', () async {
        // Create project todos
        final projectTodos = [
          ('Design UI', 'Create mockups', Priority.high, 'Design'),
          (
            'Implement Features',
            'Build core functionality',
            Priority.urgent,
            'Development',
          ),
          (
            'Write Tests',
            'Unit and integration tests',
            Priority.high,
            'Testing',
          ),
          ('Code Review', 'Review PRs', Priority.medium, 'Development'),
        ];

        for (final (title, description, priority, category) in projectTodos) {
          await service.addTodo(
            title,
            description,
            priority: priority,
            category: category,
          );
        }
        await service.loadTodos();

        // Filter by development category
        await service.applyFilter(
          TodoFilter(
            filterBy: TodoFilterBy.byCategory,
            category: 'Development',
            sortBy: TodoSortBy.priority,
            sortAscending: false,
          ),
        );

        expect(service.filteredTodos.length, 2);
        expect(service.filteredTodos.first.priority, Priority.urgent);

        // Get all categories
        final categories = await service.getAllCategories();
        expect(categories.length, 3);
        expect(categories.contains('Design'), true);
        expect(categories.contains('Development'), true);
        expect(categories.contains('Testing'), true);
      });
    });
  });
}
