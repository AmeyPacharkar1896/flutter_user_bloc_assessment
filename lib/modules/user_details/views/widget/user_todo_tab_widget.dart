import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';

class UserTodosTabWidget extends StatelessWidget {
  const UserTodosTabWidget({super.key});

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

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
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
                  // onTap: () { /* Optionally allow toggling todo completion if API supports it */ }
                ),
              );
            }, childCount: state.todos.length),
          ),
        ),
      ],
    );
  }
}
