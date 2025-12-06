import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/widgets/todo_list.dart';
import 'package:flutter_tdd/widgets/todo_item.dart';

void main() {
  group('TodoList Widget', () {
    testWidgets('should display empty message when todos list is empty',
        (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodoList(todos: []),
          ),
        ),
      );

      // Assert
      expect(find.text('No todos yet. Add one to get started!'), findsOneWidget);
    });

    testWidgets('should display todos when list is not empty', (tester) async {
      // Arrange
      final todos = [
        Todo(
          id: '1',
          title: 'Todo 1',
          description: 'Description 1',
        ),
        Todo(
          id: '2',
          title: 'Todo 2',
          description: 'Description 2',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoList(
              todos: todos,
              onToggle: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Todo 1'), findsOneWidget);
      expect(find.text('Todo 2'), findsOneWidget);
      expect(find.byType(TodoItem), findsNWidgets(2));
    });

    testWidgets('should call onToggle when todo is toggled', (tester) async {
      // Arrange
      final todos = [
        Todo(
          id: '1',
          title: 'Todo 1',
          description: 'Description 1',
        ),
      ];
      bool toggleCalled = false;
      String? toggledId;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoList(
              todos: todos,
              onToggle: (id) {
                toggleCalled = true;
                toggledId = id;
              },
              onDelete: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      expect(toggleCalled, true);
      expect(toggledId, '1');
    });

    testWidgets('should call onDelete when todo is deleted', (tester) async {
      // Arrange
      final todos = [
        Todo(
          id: '1',
          title: 'Todo 1',
          description: 'Description 1',
        ),
      ];
      bool deleteCalled = false;
      String? deletedId;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoList(
              todos: todos,
              onToggle: (_) {},
              onDelete: (id) {
                deleteCalled = true;
                deletedId = id;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Assert
      expect(deleteCalled, true);
      expect(deletedId, '1');
    });
  });
}

