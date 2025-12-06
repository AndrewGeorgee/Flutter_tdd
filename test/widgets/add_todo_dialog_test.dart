import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/widgets/add_todo_dialog.dart';

void main() {
  group('AddTodoDialog Widget', () {
    testWidgets('should display title and description fields', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddTodoDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets(
      'should call onSubmit with title and description when save is tapped',
      (tester) async {
        // Arrange
        String? submittedTitle;
        String? submittedDescription;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddTodoDialog(
                        onSubmit:
                            (
                              title,
                              description, {
                              priority,
                              category,
                              dueDate,
                            }) {
                              submittedTitle = title;
                              submittedDescription = description;
                            },
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Find and enter title
        final titleField = find.byKey(const Key('title_field'));
        await tester.ensureVisible(titleField);
        await tester.enterText(titleField, 'New Todo');

        // Find and enter description
        final descField = find.byKey(const Key('description_field'));
        await tester.ensureVisible(descField);
        await tester.enterText(descField, 'New Description');

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert
        expect(submittedTitle, 'New Todo');
        expect(submittedDescription, 'New Description');
      },
    );

    testWidgets('should allow selecting priority and category', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddTodoDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check that priority and category dropdowns exist
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is tapped', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddTodoDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
