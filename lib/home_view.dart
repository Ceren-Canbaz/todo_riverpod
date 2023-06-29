import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:todo_riverpod/models/todoModel.dart';
import 'package:todo_riverpod/providers/all_providers.dart';

class HomeView extends ConsumerWidget {
  HomeView({super.key});
  final textFieldController = TextEditingController();
  List<TodoModel> todos = [];
  var currentFilter = TodoFilter.all;
  Color _currentColor = Colors.white;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _currentColor =
        ref.watch(themeModeProvider.notifier).state == ThemeMode.light
            ? Colors.black
            : Colors.white;
    currentFilter = ref.watch(todoListFilter);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    if (ref.read(themeModeProvider.notifier).state ==
                        ThemeMode.light) {
                      ref.read(themeModeProvider.notifier).state =
                          ThemeMode.dark;
                    } else {
                      ref.read(themeModeProvider.notifier).state =
                          ThemeMode.light;
                    }
                  },
                  icon: ref.read(themeModeProvider.notifier).state !=
                          ThemeMode.light
                      ? Icon(Icons.sunny)
                      : Icon(Icons.nightlight_round)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TODAY",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "TOMORROW",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: textFieldController,
              decoration: InputDecoration(
                  labelText: "add todo",
                  labelStyle: TextStyle(
                      color: ref.watch(themeModeProvider.notifier).state ==
                              ThemeMode.light
                          ? Colors.black
                          : Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ref.watch(themeModeProvider.notifier).state ==
                                ThemeMode.light
                            ? Colors.black
                            : Colors.white,
                        width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ref.watch(themeModeProvider.notifier).state ==
                                ThemeMode.light
                            ? Colors.black
                            : Colors.white,
                        width: 1.5),
                  )),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  ref.read(todoListProvider.notifier).addTodo(value);
                  textFieldController.text = '';
                  final box = Hive.box<TodoModel>('todosBox');
                  await box.add(ref.watch(todoListProvider).last); //
                } else {}
              },
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  message: "Show all todos",
                  child: Container(
                    decoration: BoxDecoration(
                      border: ref.read(todoListFilter.notifier).state ==
                              TodoFilter.all
                          ? Border(
                              bottom: BorderSide(
                                  color: _currentColor,
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            )
                          : null,
                    ),
                    child: TextButton(
                        onPressed: () {
                          ref.read(todoListFilter.notifier).state =
                              TodoFilter.all;
                        },
                        child: Text(
                          "All ${ref.watch(todoListProvider).length}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Tooltip(
                  message: "Show Completed todos",
                  child: Container(
                    decoration: BoxDecoration(
                      border: ref.read(todoListFilter.notifier).state ==
                              TodoFilter.completed
                          ? Border(
                              bottom: BorderSide(
                                  color: _currentColor,
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            )
                          : null,
                    ),
                    child: TextButton(
                        onPressed: () {
                          ref.read(todoListFilter.notifier).state =
                              TodoFilter.completed;
                        },
                        child: Text(
                          "Completed ${ref.watch(completedTodoCount)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Tooltip(
                  message: "Show Active todos",
                  child: Container(
                    decoration: BoxDecoration(
                      border: ref.read(todoListFilter.notifier).state ==
                              TodoFilter.active
                          ? Border(
                              bottom: BorderSide(
                                  color: _currentColor,
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            )
                          : null,
                    ),
                    child: TextButton(
                        onPressed: () {
                          ref.read(todoListFilter.notifier).state =
                              TodoFilter.active;
                        },
                        child: Text(
                          "Active ${ref.watch(activeTodoCount)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )),
                  ),
                )
              ],
            ),
            Expanded(child: TodoList())
          ]),
        ),
      ),
    );
  }
}

class TodoList extends ConsumerWidget {
  const TodoList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var todos = ref.watch(filteredTodoList);
    return todos.isNotEmpty
        ? ListView(
            children: todos
                .map((e) => Dismissible(
                      key: ValueKey(e.id),
                      onDismissed: (_) {
                        ref.read(todoListProvider.notifier).remove(e.id);
                      },
                      child: ProviderScope(
                          overrides: [currentTodo.overrideWithValue(e)],
                          child: TodoItem()),
                    ))
                .toList(),
          )
        : Center(
            child: Builder(
              builder: (BuildContext context) {
                final todoFilter = ref.read(todoListFilter.notifier).state;
                switch (todoFilter) {
                  case TodoFilter.all:
                    return Text(
                      "Your to-do list is empty, do you want to add new tasks?",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    );
                  case TodoFilter.completed:
                    return Text(
                      "You haven't completed any of your work",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    );
                  case TodoFilter.active:
                    return Text(
                      "You have finished all the things to do, congratulations!",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    );
                  default:
                    return Text("Invalid filter");
                }
              },
            ),
          );
  }
}

class TodoItem extends ConsumerStatefulWidget {
  const TodoItem({
    super.key,
  });

  @override
  ConsumerState<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends ConsumerState<TodoItem> {
  late FocusNode _todoFocusNode;
  late TextEditingController _textEditingController;
  bool _hasFocus = false;
  @override
  void initState() {
    super.initState();
    _todoFocusNode = FocusNode();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textEditingController.dispose();
    _todoFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTodoItem = ref.watch(currentTodo);

    return Focus(
      onFocusChange: (value) {
        if (!value) {
          setState(() {
            _hasFocus = false;
            ref
                .read(todoListProvider.notifier)
                .edit(currentTodoItem.id, _textEditingController.text);
          });
        }
      },
      child: ListTile(
        contentPadding: EdgeInsets.all(4),
        onTap: () {
          setState(() {
            _hasFocus = true;
            _todoFocusNode.requestFocus();
            _textEditingController.text = currentTodoItem.description;
          });
        },
        leading: Checkbox(
            activeColor: Colors.white,
            checkColor: Colors.black,
            value: !currentTodoItem.active,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onChanged: (value) {
              ref.read(todoListProvider.notifier).toggle(currentTodoItem.id);
            }),
        title: _hasFocus
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: TextField(
                  controller: _textEditingController,
                  focusNode: _todoFocusNode,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: ref.watch(themeModeProvider.notifier).state ==
                                  ThemeMode.light
                              ? Colors.black
                              : Colors.white,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  onSubmitted: (value) {
                    ref
                        .read(todoListProvider.notifier)
                        .edit(currentTodoItem.id, value);
                  },
                ),
              )
            : Text(currentTodoItem.description),
      ),
    );
  }
}
