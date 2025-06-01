import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';

class UserPostsTabWidget extends StatelessWidget {
  const UserPostsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // It's often better to select specific parts of the state
    // to avoid unnecessary rebuilds if other parts of UserDetailState change.
    // However, for simplicity here, we listen to the whole state.
    final state = context.watch<UserDetailsBloc>().state;

    if (state.postsStatus == UserDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.postsStatus == UserDetailsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.errorMessage ?? 'Failed to load posts. Please try refreshing.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state.posts.isEmpty) {
      return const Center(child: Text('No posts found for this user.'));
    }

    // Ensure the content is scrollable within the TabBarView
    // CustomScrollView and SliverList are good for performance with Slivers
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = state.posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.body,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 4, // Show a bit more
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Views: ${post.views}', style: Theme.of(context).textTheme.bodySmall),
                            Row(
                              children: [
                                Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text('${post.reactions.likes}', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(width: 8),
                                Icon(Icons.thumb_down_alt_outlined, size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text('${post.reactions.dislikes}', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                        if (post.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 4.0,
                            children: post.tags.map((tag) => Chip(
                              label: Text(tag, style: Theme.of(context).textTheme.labelSmall),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
              childCount: state.posts.length,
            ),
          ),
        ),
      ],
    );
  }
}