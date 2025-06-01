// file: lib/modules/user_details/views/widget/user_todo_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';

class UserTodosTabWidget extends StatelessWidget {
  final double topPadding; // To receive the estimated TabBar height

  const UserTodosTabWidget({super.key, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserDetailsBloc>().state;

    if (state.todosStatus == UserDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.todosStatus == UserDetailsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.errorMessage ??
                'Failed to load todos. Please try refreshing.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state.todos.isEmpty) {
      return const Center(child: Text('No todos found for this user.'));
    }

    return ListView.builder(
      // Apply padding: topPadding for the TabBar, +8.0 for general list padding
      padding: EdgeInsets.fromLTRB(8.0, topPadding + 8.0, 8.0, 8.0),
      itemCount: state.todos.length, // Or 50 for testing
      itemBuilder: (context, index) {
        // FOR TESTING with 50 items:
        // if (state.todos.isEmpty) {
        //   return Card(child: ListTile(title: Text('Test Todo Item ${index + 1} for padding')));
        // }
        // final todo = state.todos[index % state.todos.length];
        final todo = state.todos[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          elevation: 1.5,
          child: ListTile(
            title: Text(
              todo.todo,
              style:
                  todo.completed
                      ? TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade600,
                      )
                      : null,
            ),
            trailing: Icon(
              todo.completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked_outlined,
              color:
                  todo.completed
                      ? Colors.green
                      : Theme.of(context).disabledColor,
            ),
          ),
        );
      },
    );
  }
}
