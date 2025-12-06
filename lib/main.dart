import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/todo_repository.dart';
import 'services/todo_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final repository = TodoRepository();
        final service = TodoService(repository);
        service.loadTodos();
        return service;
      },
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
