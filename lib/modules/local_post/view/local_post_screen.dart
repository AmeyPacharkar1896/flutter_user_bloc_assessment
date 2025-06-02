// file: lib/modules/local_post/presentation/local_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/bloc/local_post_bloc.dart';
// Assuming LocalPostModel is accessible, ensure the import if needed
// import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';

class LocalPostScreen extends StatelessWidget {
  const LocalPostScreen({super.key});

  Future<void> _refreshPosts(BuildContext context) async {
    context.read<LocalPostBloc>().add(LocalPostEventLoad());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalPostBloc, LocalPostState>(
      // Use BlocConsumer
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2), // Optional: set duration
              ),
            );
          // Important: We need to tell the BLoC to clear the success message
          // so it doesn't show again on unrelated rebuilds.
          // This could be a new event, or the BLoC can auto-clear it.
          // For now, let's assume the BLoC handles clearing it when it emits the message
          // (e.g. by emitting it once and then subsequent states don't have it,
          // or by using `state.copyWith(clearSuccess: true)` in the next relevant state emission).
          // The CreatePostBloc already does this with clearSuccess flag.
        }
        // Optionally, handle errors via SnackBar too, though builder handles primary error UI
        // if (state.status == LocalPostStatus.failure && state.errorMessage != null && !state.posts.isNotEmpty) {
        //   ScaffoldMessenger.of(context)
        //     ..hideCurrentSnackBar()
        //     ..showSnackBar(
        //       SnackBar(
        //         content: Text('Error: ${state.errorMessage}'),
        //         backgroundColor: Theme.of(context).colorScheme.error,
        //       ),
        //     );
        // }
      },
      builder: (context, state) {
        // Handle initial loading or loading when posts list is empty
        if (state.status == LocalPostStatus.loading && state.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle failure state
        if (state.status == LocalPostStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Failed to load local posts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => context.read<LocalPostBloc>().add(
                          LocalPostEventLoad(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle empty state (even after successful load/refresh if no posts exist)
        if (state.posts.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _refreshPosts(context), // Use helper
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No local posts yet.',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pull down to refresh, or create a new post.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Display the list of posts with RefreshIndicator
        return RefreshIndicator(
          onRefresh: () => _refreshPosts(context), // Use helper
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ), // Adjusted padding
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 6.0,
                ), // Removed horizontal from here, handled by ListView padding
                elevation: 2.5, // Slightly increased elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ), // More rounded
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  title: Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ), // Increased top padding
                    child: Text(
                      post.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ), // Improved readability
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_forever_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: 'Delete Post',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text(
                              'Are you sure you want to delete the post "${post.title}"? This action cannot be undone.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed:
                                    () => Navigator.of(dialogContext).pop(),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('Delete'),
                                onPressed: () {
                                  context.read<LocalPostBloc>().add(
                                    LocalPostEventDelete(postId: post.id),
                                  );
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
