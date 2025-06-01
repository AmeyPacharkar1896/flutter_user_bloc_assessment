import 'package:equatable/equatable.dart';
import 'todo_model.dart'; // Assuming todo_model.dart is in the same directory

class TodoListResponse extends Equatable {
  final List<Todo> todos;
  final int total;
  final int skip;
  final int limit;

  const TodoListResponse({
    required this.todos,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory TodoListResponse.fromJson(Map<String, dynamic> json) {
    var todoList =
        (json['todos'] as List<dynamic>?)
            ?.map((todoJson) => Todo.fromJson(todoJson as Map<String, dynamic>))
            .toList() ??
        <Todo>[];

    return TodoListResponse(
      todos: todoList,
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todos': todos.map((todo) => todo.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }

  TodoListResponse copyWith({
    List<Todo>? todos,
    int? total,
    int? skip,
    int? limit,
  }) {
    return TodoListResponse(
      todos: todos ?? this.todos,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [todos, total, skip, limit];
}
