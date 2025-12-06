import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/todo.dart';
import 'package:flutter_tdd/widgets/todo_item.dart';

void main() {
  group('TodoItem Widget', () {
    testWidgets('should display todo title and description', (tester) async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onToggle: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Todo'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should show completed checkbox when todo is completed',
        (tester) async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: true,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onToggle: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );

      // Assert
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('should call onToggle when checkbox is tapped', (tester) async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );
      bool toggleCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onToggle: (_) {
                toggleCalled = true;
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
    });

    testWidgets('should call onDelete when delete button is tapped',
        (tester) async {
      // Arrange
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
      );
      bool deleteCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onToggle: (_) {},
              onDelete: (_) {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Assert
      expect(deleteCalled, true);
    });
  });
}

