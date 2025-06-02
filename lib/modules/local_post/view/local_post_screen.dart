import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/bloc/local_post_bloc.dart';

class LocalPostScreen extends StatelessWidget {
  const LocalPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocalPostBloc, LocalPostState>(
        builder: (context, state) {
          if (state.status == LocalPostStatus.loading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == LocalPostStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load local posts.'),
                  ElevatedButton(
                    onPressed:
                        () => context.read<LocalPostBloc>().add(
                          LocalPostEventLoad(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.posts.isEmpty) {
            return const Center(child: Text('No local posts available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      post.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
