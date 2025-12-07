import '../models/todo.dart';
import '../models/priority.dart';
import '../models/todo_filter.dart';

/// Abstract interface for TodoRepository to enable dependency injection and mocking
abstract class TodoRepositoryInterface {
  Future<List<Todo>> getAllTodos();
  Future<Todo?> getTodoById(String id);
  Future<void> addTodo(Todo todo);
  Future<void> updateTodo(Todo updatedTodo);
  Future<void> deleteTodo(String id);
  Future<List<Todo>> getCompletedTodos();
  Future<List<Todo>> getPendingTodos();
  Future<List<Todo>> searchTodos(String query);
  Future<List<Todo>> getTodosByCategory(String category);
  Future<List<Todo>> getTodosByPriority(Priority priority);
  Future<List<Todo>> getOverdueTodos();
  Future<List<Todo>> getDueSoonTodos();
  Future<List<String>> getAllCategories();
  Future<List<Todo>> filterAndSortTodos(TodoFilter filter);
}
