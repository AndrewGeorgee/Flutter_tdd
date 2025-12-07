import '../models/todo.dart';
import '../models/priority.dart';
import '../models/todo_filter.dart';
import 'todo_repository_interface.dart';

class TodoRepository implements TodoRepositoryInterface {
  final List<Todo> _todos = [];

  Future<List<Todo>> getAllTodos() async {
    return List.unmodifiable(_todos);
  }

  Future<Todo?> getTodoById(String id) async {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
  }

  Future<List<Todo>> getCompletedTodos() async {
    return _todos.where((todo) => todo.isCompleted).toList();
  }

  Future<List<Todo>> getPendingTodos() async {
    return _todos.where((todo) => !todo.isCompleted).toList();
  }

  Future<List<Todo>> searchTodos(String query) async {
    final lowerQuery = query.toLowerCase();
    return _todos
        .where(
          (todo) =>
              todo.title.toLowerCase().contains(lowerQuery) ||
              todo.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  Future<List<Todo>> getTodosByCategory(String category) async {
    return _todos.where((todo) => todo.category == category).toList();
  }

  Future<List<Todo>> getTodosByPriority(Priority priority) async {
    return _todos.where((todo) => todo.priority == priority).toList();
  }

  Future<List<Todo>> getOverdueTodos() async {
    return _todos.where((todo) => todo.isOverdue).toList();
  }

  Future<List<Todo>> getDueSoonTodos() async {
    return _todos.where((todo) => todo.isDueSoon).toList();
  }

  Future<List<String>> getAllCategories() async {
    final categories = _todos
        .where((todo) => todo.category.isNotEmpty)
        .map((todo) => todo.category)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<List<Todo>> filterAndSortTodos(TodoFilter filter) async {
    var result = List<Todo>.from(_todos);

    // Apply filters
    switch (filter.filterBy) {
      case TodoFilterBy.all:
        break;
      case TodoFilterBy.pending:
        result = result.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilterBy.completed:
        result = result.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilterBy.overdue:
        result = result.where((todo) => todo.isOverdue).toList();
        break;
      case TodoFilterBy.dueSoon:
        result = result.where((todo) => todo.isDueSoon).toList();
        break;
      case TodoFilterBy.byCategory:
        if (filter.category != null) {
          result = result
              .where((todo) => todo.category == filter.category)
              .toList();
        }
        break;
      case TodoFilterBy.byPriority:
        if (filter.priority != null) {
          result = result
              .where((todo) => todo.priority == filter.priority)
              .toList();
        }
        break;
    }

    // Apply search query
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      result = result
          .where(
            (todo) =>
                todo.title.toLowerCase().contains(query) ||
                todo.description.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison = 0;
      switch (filter.sortBy) {
        case TodoSortBy.priority:
          comparison = a.priority.value.compareTo(b.priority.value);
          break;
        case TodoSortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          comparison = a.dueDate!.compareTo(b.dueDate!);
          break;
        case TodoSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case TodoSortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
      }
      return filter.sortAscending ? comparison : -comparison;
    });

    return result;
  }
}
