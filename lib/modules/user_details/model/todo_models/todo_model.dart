import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final String todo; // The task description
  final bool completed;
  final int userId;

  const Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int? ?? 0,
      todo: json['todo'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'todo': todo, 'completed': completed, 'userId': userId};
  }

  Todo copyWith({int? id, String? todo, bool? completed, int? userId}) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, todo, completed, userId];
}
