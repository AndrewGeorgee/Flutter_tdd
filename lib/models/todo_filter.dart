import 'priority.dart';

enum TodoSortBy {
  priority,
  dueDate,
  createdAt,
  title,
}

enum TodoFilterBy {
  all,
  pending,
  completed,
  overdue,
  dueSoon,
  byCategory,
  byPriority,
}

class TodoFilter {
  final TodoFilterBy filterBy;
  final TodoSortBy sortBy;
  final String? category;
  final Priority? priority;
  final String? searchQuery;
  final bool sortAscending;

  const TodoFilter({
    this.filterBy = TodoFilterBy.all,
    this.sortBy = TodoSortBy.priority,
    this.category,
    this.priority,
    this.searchQuery,
    this.sortAscending = false,
  });

  TodoFilter copyWith({
    TodoFilterBy? filterBy,
    TodoSortBy? sortBy,
    String? category,
    Priority? priority,
    String? searchQuery,
    bool? sortAscending,
  }) {
    return TodoFilter(
      filterBy: filterBy ?? this.filterBy,
      sortBy: sortBy ?? this.sortBy,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      searchQuery: searchQuery ?? this.searchQuery,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

