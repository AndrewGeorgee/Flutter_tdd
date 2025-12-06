# Flutter TDD Todo App

A comprehensive Todo application built with Flutter using Test-Driven Development (TDD) principles. This project demonstrates clean architecture, comprehensive test coverage, and modern Flutter development practices.

## Features

### Core Functionality
- ✅ Create, read, update, and delete todos
- ✅ Mark todos as completed/incomplete
- ✅ Search todos by title or description
- ✅ Filter todos by status, category, priority, or due date
- ✅ Sort todos by priority, due date, creation date, or title

### Advanced Features
- **Priority System**: 4 levels (Low, Medium, High, Urgent) with visual indicators
- **Categories**: Organize todos with custom categories
- **Due Dates**: Set and track due dates with overdue/due soon detection
- **Smart Filtering**: Filter by completion status, category, priority, overdue items, or due soon items
- **Real-time Search**: Instant search across todo titles and descriptions
- **Statistics**: View counts for pending, completed, overdue, and due soon todos

## Architecture

The app follows a clean, layered architecture:

```
lib/
├── models/          # Data models (Todo, Priority, TodoFilter)
├── repositories/    # Data access layer
├── services/        # Business logic layer
├── widgets/         # Reusable UI components
├── screens/         # Page-level widgets
└── main.dart        # App entry point
```

### Layer Responsibilities

- **Models**: Immutable data structures with business logic (isOverdue, isDueSoon)
- **Repositories**: Data persistence and retrieval operations
- **Services**: Business logic, state management (ChangeNotifier), and validation
- **Widgets**: Reusable, testable UI components
- **Screens**: Page composition and navigation

## Tech Stack

- **Flutter**: UI framework
- **Provider**: State management
- **UUID**: Unique ID generation
- **Flutter Test**: Testing framework

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter_tdd
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Testing

This project follows Test-Driven Development (TDD) principles. All features were developed by writing tests first, then implementing the functionality.

### Running Tests

Run all tests:
```bash
flutter test
```

Run specific test files:
```bash
flutter test test/models/todo_test.dart
flutter test test/repositories/todo_repository_test.dart
flutter test test/services/todo_service_test.dart
flutter test test/widgets/
flutter test test/integration/
```

### Test Coverage

The project includes comprehensive test coverage:

- **Model Tests**: 14 tests covering data structures, business logic, and serialization
- **Repository Tests**: 12 tests covering CRUD operations, filtering, and sorting
- **Service Tests**: 13 tests covering business logic and state management
- **Widget Tests**: 9 tests covering UI components and interactions
- **Integration Tests**: 4 tests covering end-to-end user flows

**Total: 52+ tests** ensuring high code quality and reliability.

## Project Structure

```
flutter_tdd/
├── lib/
│   ├── models/
│   │   ├── priority.dart          # Priority enum with value mapping
│   │   ├── todo.dart              # Todo model with business logic
│   │   └── todo_filter.dart       # Filter and sort configuration
│   ├── repositories/
│   │   └── todo_repository.dart  # Data access layer
│   ├── services/
│   │   └── todo_service.dart     # Business logic and state management
│   ├── widgets/
│   │   ├── add_todo_dialog.dart   # Add/edit todo dialog
│   │   ├── todo_item.dart         # Individual todo item widget
│   │   └── todo_list.dart        # Todo list widget
│   ├── screens/
│   │   └── home_screen.dart       # Main screen
│   └── main.dart                  # App entry point
├── test/
│   ├── models/                    # Model unit tests
│   ├── repositories/              # Repository unit tests
│   ├── services/                  # Service unit tests
│   ├── widgets/                   # Widget tests
│   ├── integration/               # Integration tests
│   └── widget_test.dart           # App-level test
└── README.md
```

## TDD Approach

This project strictly follows the Red-Green-Refactor cycle:

1. **Red**: Write a failing test that describes the desired behavior
2. **Green**: Write the minimum code to make the test pass
3. **Refactor**: Improve the code while keeping tests green

### Example TDD Flow

```dart
// 1. Write test first (RED)
test('should create todo with priority', () {
  final todo = Todo(
    id: '1',
    title: 'Test',
    description: 'Test',
    priority: Priority.high,
  );
  expect(todo.priority, Priority.high);
});

// 2. Implement minimum code (GREEN)
class Todo {
  final Priority priority;
  // ... implementation
}

// 3. Refactor if needed
```

## Key Design Patterns

### Immutability
- All models use `final` fields
- `copyWith` pattern for updates
- Immutable lists returned from repositories

### Repository Pattern
- Abstracts data access
- Easy to swap implementations (in-memory → database → API)

### Service Layer
- Encapsulates business logic
- Manages application state
- Provides clean API for UI

### Provider Pattern
- State management with ChangeNotifier
- Reactive UI updates
- Dependency injection

## Code Quality

### Best Practices Followed

- ✅ Immutable data models
- ✅ Comprehensive error handling
- ✅ Null safety throughout
- ✅ Clear separation of concerns
- ✅ Single Responsibility Principle
- ✅ DRY (Don't Repeat Yourself)
- ✅ Meaningful naming conventions
- ✅ Consistent code formatting

### Code Metrics

- **Test Coverage**: High (52+ tests)
- **Code Organization**: Clean layered architecture
- **Maintainability**: Excellent (clear structure, well-tested)
- **Performance**: Optimized (ListView.builder, const constructors)

## Usage Examples

### Creating a Todo

```dart
await todoService.addTodo(
  'Complete project',
  'Finish the Flutter TDD app',
  priority: Priority.high,
  category: 'Work',
  dueDate: DateTime.now().add(Duration(days: 7)),
);
```

### Filtering Todos

```dart
final filter = TodoFilter(
  filterBy: TodoFilterBy.byCategory,
  category: 'Work',
  sortBy: TodoSortBy.priority,
  sortAscending: false,
);
await todoService.applyFilter(filter);
```

### Searching Todos

```dart
await todoService.searchTodos('grocery');
```

## Future Enhancements

Potential improvements for the project:

- [ ] Persistent storage (SQLite, Hive, or SharedPreferences)
- [ ] Cloud sync functionality
- [ ] Todo editing capability
- [ ] Subtasks support
- [ ] Todo attachments
- [ ] Dark mode
- [ ] Localization
- [ ] Analytics and statistics dashboard
- [ ] Export/import functionality
- [ ] Reminder notifications

## Contributing

When contributing to this project:

1. Follow TDD principles - write tests first
2. Maintain test coverage above 90%
3. Follow existing code style and architecture
4. Write clear, descriptive commit messages
5. Update tests and documentation as needed

## License

This project is open source and available for educational purposes.

## Acknowledgments

Built as a demonstration of:
- Test-Driven Development in Flutter
- Clean Architecture principles
- Flutter best practices
- Comprehensive testing strategies

---

**Happy Coding! 🚀**
