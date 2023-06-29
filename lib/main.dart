import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:todo_riverpod/home_view.dart';
import 'package:todo_riverpod/models/todoModel.dart';
import 'package:todo_riverpod/providers/all_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var path = Directory.systemTemp.path;
  Hive
    ..init(path)
    ..registerAdapter(TodoModelAdapter());

  if (!Hive.isBoxOpen('todosBox')) {
    await Hive.openBox<TodoModel>('todosBox');
  }

  runApp(ProviderScope(child: MyApp()));
}

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  brightness: Brightness.light,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.black,
  ),
  textTheme: const TextTheme(
      headlineMedium:
          TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      headlineSmall: TextStyle(
          color: Colors.grey,
          decoration: TextDecoration.lineThrough,
          fontWeight: FontWeight.w500)),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.white,
  ),
  textTheme: const TextTheme(
      headlineMedium:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      headlineSmall: TextStyle(
          color: Colors.grey,
          decoration: TextDecoration.lineThrough,
          fontWeight: FontWeight.w500)),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: themeMode == ThemeMode.light ? lightTheme : darkTheme,
        darkTheme: darkTheme,
        home: HomeView());
  }
}
