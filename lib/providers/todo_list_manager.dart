import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';
import 'package:todo_riverpod/models/todoModel.dart';

class TodoListManager extends StateNotifier<List<TodoModel>> {
  final box = Hive.box<TodoModel>('todosBox');
  TodoListManager([List<TodoModel>? initialTodos]) : super(initialTodos ?? []);
  void addTodo(String description) {
    state = [...state, TodoModel(description: description, active: true)];
  }

  void toggle(String id) {
    state = state.map((element) {
      if (element.id == id) {
        return element.copyWith(active: !element.active);
      } else {
        return element;
      }
    }).toList();
  }

  void edit(String id, String description) {
    state = state
        .map((element) => element.id == id
            ? element.copyWith(description: description)
            : element)
        .toList();

    final index = box.values.toList().indexWhere((element) => element.id == id);
    if (index != -1) {
      final todo = box.getAt(index);
      final editedTodo = todo?.copyWith(description: description);
      box.putAt(index, editedTodo!);
    }
  }

  void remove(String id) {
    state = state.where((element) => element.id != id).toList();
    final index = box.values.toList().indexWhere((element) => element.id == id);
    if (index != -1) {
      box.deleteAt(index);
    }
  }

  List<TodoModel> onCompletedTodo() {
    return state.where((element) => element.active == false).toList();
  }
}
