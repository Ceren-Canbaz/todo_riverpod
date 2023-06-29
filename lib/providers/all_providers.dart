import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';
import 'package:todo_riverpod/models/todoModel.dart';
import 'package:todo_riverpod/providers/todo_list_manager.dart';

final todoListProvider =
    StateNotifierProvider<TodoListManager, List<TodoModel>>(
  (ref) {
    final box = Hive.box<TodoModel>('todosBox');
    final List<TodoModel> todoList = [];

    for (var i = 0; i < box.length; i++) {
      final todo = box.getAt(i) as TodoModel;
      todoList.add(todo);
    }

    return TodoListManager(todoList);
  },
);

final completedTodoCount = Provider<int>((ref) {
  final allTodo = ref.watch(todoListProvider);
  final count = allTodo.where((element) => !element.active).length;
  return count;
});

final activeTodoCount = Provider<int>((ref) {
  final allTodo = ref.watch(todoListProvider);
  final count = allTodo.where((element) => element.active).length;
  return count;
});

final currentTodo = Provider<TodoModel>((ref) {
  throw UnimplementedError();
});

enum TodoFilter { all, active, completed }

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

final todoListFilter = StateProvider<TodoFilter>((ref) {
  return TodoFilter.all;
});
final filteredTodoList = Provider<List<TodoModel>>((ref) {
  final filter = ref.watch(todoListFilter);
  final todoList = ref.watch(todoListProvider);
  switch (filter) {
    case TodoFilter.all:
      return todoList;
    case TodoFilter.active:
      return todoList.where((element) => element.active).toList();
    case TodoFilter.completed:
      return todoList.where((element) => !element.active).toList();
  }
});
