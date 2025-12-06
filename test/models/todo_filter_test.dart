import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo_filter.dart';
import 'package:flutter_tdd/models/priority.dart';

void main() {
  group('TodoFilter', () {
    test('should create filter with default values', () {
      // Act
      const filter = TodoFilter();

      // Assert
      expect(filter.filterBy, TodoFilterBy.all);
      expect(filter.sortBy, TodoSortBy.priority);
      expect(filter.category, isNull);
      expect(filter.priority, isNull);
      expect(filter.searchQuery, isNull);
      expect(filter.sortAscending, false);
    });

    test('should create filter with custom values', () {
      // Act
      const filter = TodoFilter(
        filterBy: TodoFilterBy.overdue,
        sortBy: TodoSortBy.dueDate,
        category: 'Work',
        priority: Priority.high,
        searchQuery: 'test',
        sortAscending: true,
      );

      // Assert
      expect(filter.filterBy, TodoFilterBy.overdue);
      expect(filter.sortBy, TodoSortBy.dueDate);
      expect(filter.category, 'Work');
      expect(filter.priority, Priority.high);
      expect(filter.searchQuery, 'test');
      expect(filter.sortAscending, true);
    });

    test('should copy with updated values', () {
      // Arrange
      const original = TodoFilter(
        filterBy: TodoFilterBy.all,
        sortBy: TodoSortBy.priority,
      );

      // Act
      final updated = original.copyWith(
        filterBy: TodoFilterBy.completed,
        searchQuery: 'new query',
      );

      // Assert
      expect(updated.filterBy, TodoFilterBy.completed);
      expect(updated.sortBy, TodoSortBy.priority); // Unchanged
      expect(updated.searchQuery, 'new query');
      expect(original.filterBy, TodoFilterBy.all); // Original unchanged
    });
  });
}

