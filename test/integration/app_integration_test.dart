import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tdd/repositories/todo_repository.dart';
import 'package:flutter_tdd/services/todo_service.dart';
import 'package:flutter_tdd/screens/home_screen.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('should add a todo and display it in the list', (tester) async {
      // Arrange
      final repository = TodoRepository();
      final service = TodoService(repository);

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TodoService>.value(
          value: service,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Tap FAB to open add dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter todo details
      await tester.enterText(
        find.byType(TextFormField).first,
        'Integration Test Todo',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Integration Test Description',
      );

      // Save todo
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Integration Test Todo'), findsOneWidget);
      expect(find.text('Integration Test Description'), findsOneWidget);
    });

    testWidgets('should toggle todo completion', (tester) async {
      // Arrange
      final repository = TodoRepository();
      final service = TodoService(repository);
      await service.addTodo('Test Todo', 'Test Description');
      await service.loadTodos();

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TodoService>.value(
          value: service,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Toggle checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Assert
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('should delete a todo', (tester) async {
      // Arrange
      final repository = TodoRepository();
      final service = TodoService(repository);
      await service.addTodo('Test Todo', 'Test Description');
      await service.loadTodos();

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TodoService>.value(
          value: service,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Delete todo
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Todo'), findsNothing);
      expect(
        find.text('No todos yet. Add one to get started!'),
        findsOneWidget,
      );
    });

    testWidgets('should update todo counts in app bar', (tester) async {
      // Arrange
      final repository = TodoRepository();
      final service = TodoService(repository);
      await service.addTodo('Todo 1', 'Description 1');
      await service.addTodo('Todo 2', 'Description 2');
      await service.loadTodos();

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TodoService>.value(
          value: service,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pending: 2'), findsOneWidget);
      expect(find.text('Completed: 0'), findsOneWidget);

      // Toggle one todo
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // Assert updated counts
      expect(find.text('Pending: 1'), findsOneWidget);
      expect(find.text('Completed: 1'), findsOneWidget);
    });
  });
}
