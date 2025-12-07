import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../models/priority.dart';
import '../models/todo_filter.dart';
import '../repositories/todo_repository_interface.dart';
import 'package:uuid/uuid.dart';

class TodoService extends ChangeNotifier {
  final TodoRepositoryInterface _repository;
  final List<Todo> _todos = [];
  final List<Todo> _filteredTodos = [];
  TodoFilter _currentFilter = const TodoFilter();
  final Uuid _uuid = const Uuid();

  TodoService(this._repository);

  List<Todo> get todos => List.unmodifiable(_todos);
  List<Todo> get filteredTodos => List.unmodifiable(_filteredTodos);
  TodoFilter get currentFilter => _currentFilter;

  Future<void> loadTodos() async {
    _todos.clear();
    _todos.addAll(await _repository.getAllTodos());
    await _applyCurrentFilter();
    notifyListeners();
  }

  Future<void> _applyCurrentFilter() async {
    final filtered = await _repository.filterAndSortTodos(_currentFilter);
    _filteredTodos.clear();
    _filteredTodos.addAll(filtered);
    notifyListeners();
  }

  Future<void> addTodo(
    String title,
    String description, {
    Priority? priority,
    String? category,
    DateTime? dueDate,
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    final todo = Todo(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      category: category,
      dueDate: dueDate,
    );

    await _repository.addTodo(todo);
    await loadTodos();
  }

  Future<void> toggleTodoCompletion(String id) async {
    final todo = await _repository.getTodoById(id);
    if (todo != null) {
      final updatedTodo = todo.toggleCompletion();
      await _repository.updateTodo(updatedTodo);
      await loadTodos();
    }
  }

  Future<void> deleteTodo(String id) async {
    await _repository.deleteTodo(id);
    await loadTodos();
  }

  int getCompletedCount() {
    return _todos.where((todo) => todo.isCompleted).length;
  }

  int getPendingCount() {
    return _todos.where((todo) => !todo.isCompleted).length;
  }

  Future<void> applyFilter(TodoFilter filter) async {
    _currentFilter = filter;
    await _applyCurrentFilter();
  }

  Future<void> searchTodos(String query) async {
    _currentFilter = _currentFilter.copyWith(
      searchQuery: query.isEmpty ? null : query,
    );
    await _applyCurrentFilter();
  }

  Future<void> clearFilter() async {
    _currentFilter = const TodoFilter();
    await _applyCurrentFilter();
  }

  Future<List<String>> getAllCategories() async {
    return await _repository.getAllCategories();
  }

  int getOverdueCount() {
    return _todos.where((todo) => todo.isOverdue).length;
  }

  int getDueSoonCount() {
    return _todos.where((todo) => todo.isDueSoon).length;
  }
}
