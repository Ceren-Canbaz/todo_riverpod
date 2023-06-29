import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todoModel.g.dart';

@HiveType(typeId: 1)
class TodoModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final bool active;

  TodoModel({required this.description, required this.active})
      : id = Uuid().v4();

  factory TodoModel.empty() {
    return TodoModel(description: "", active: false);
  }
  TodoModel copyWith({String? id, String? description, bool? active}) {
    return TodoModel(
        description: description ?? this.description,
        active: active ?? this.active);
  }
}
