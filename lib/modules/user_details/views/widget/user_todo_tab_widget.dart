// file: lib/modules/user_details/views/widget/user_todo_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
// Assuming your Todo model is here:
// import 'package:flutter_user_bloc_assessment/core/models/todo_models/todo_model.dart';

class UserTodosTabWidget extends StatelessWidget {
  const UserTodosTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the BLoC state for updates
    final state = context.watch<UserDetailsBloc>().state;

    // Handle loading state for todos
    if (state.todosStatus == UserDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle failure state for todos
    if (state.todosStatus == UserDetailsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? 'Failed to load todos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final userId = state.user?.id;
                  if (userId != null) {
                    context.read<UserDetailsBloc>().add(
                      UserDetailsEventFetchAllDetails(
                        userId: userId,
                        initialUser: state.user,
                      ),
                      // Or a more specific event like FetchUserTodosEvent(userId)
                    );
                  }
                },
                child: const Text('Retry Todos'),
              ),
            ],
          ),
        ),
      );
    }

    // Handle empty state for todos
    if (state.todos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No todos found for this user.'),
        ),
      );
    }

    // Display the list of todos
    return ListView.builder(
      padding: const EdgeInsets.all(8.0), // General padding for the list
      itemCount: state.todos.length,
      itemBuilder: (context, index) {
        final todo = state.todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text(
              todo.todo,
              style:
                  todo.completed
                      ? TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
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
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
            ),
            // You could add an onTap to toggle completion if your API and BLoC supported it
            // onTap: () {
            //   // Dispatch event to toggle todo status
            // },
          ),
        );
      },
    );
  }
}
