// file: lib/modules/user_details/views/widget/user_post_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
// Assuming your Post model is here:
// import 'package:flutter_user_bloc_assessment/core/models/post_models/post_model.dart';

class UserPostsTabWidget extends StatelessWidget {
  const UserPostsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the BLoC state for updates
    final state = context.watch<UserDetailsBloc>().state;

    // Handle loading state for posts
    if (state.postsStatus == UserDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle failure state for posts
    if (state.postsStatus == UserDetailsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? 'Failed to load posts.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // To retry, we need the userId. Assuming UserDetailsBloc holds it
                  // or we can get it from the state.user if it's loaded.
                  final userId = state.user?.id;
                  if (userId != null) {
                    context.read<UserDetailsBloc>().add(
                      UserDetailsEventFetchAllDetails(
                        userId: userId,
                        initialUser: state.user,
                      ),
                      // Or a more specific event like FetchUserPostsEvent(userId) if you create one
                    );
                  }
                },
                child: const Text('Retry Posts'),
              ),
            ],
          ),
        ),
      );
    }

    // Handle empty state for posts
    if (state.posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No posts found for this user.'),
        ),
      );
    }

    // Display the list of posts
    return ListView.builder(
      padding: const EdgeInsets.all(8.0), // General padding for the list
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                  // maxLines: 4, // Keep if you want to limit lines
                  // overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Views: ${post.views}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.reactions.likes}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.thumb_down_alt_outlined,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.reactions.dislikes}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children:
                        post.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                labelStyle:
                                    Theme.of(context).textTheme.labelSmall,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 0.0,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
