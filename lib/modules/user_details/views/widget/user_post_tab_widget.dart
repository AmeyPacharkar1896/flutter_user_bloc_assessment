import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
// Uncomment and adjust import below if you want Post model typing
// import 'package:flutter_user_bloc_assessment/modules/user_details/model/post_models/post_model.dart';

class UserPostsTabWidget extends StatelessWidget {
  const UserPostsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserDetailsBloc>().state;

    // Loading state
    if (state.postsStatus == UserDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Failure state
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
                  final userId = state.user?.id;
                  if (userId != null) {
                    context.read<UserDetailsBloc>().add(
                      UserDetailsEventFetchAllDetails(
                        userId: userId,
                        initialUser: state.user,
                      ),
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

    // Empty posts list
    if (state.posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No posts found for this user.'),
        ),
      );
    }

    // Success: Show posts list
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
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
                Text(post.body, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color
                                ?..withAlpha((0.7 * 255).toInt()),
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
