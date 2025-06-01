// file: lib/modules/user_details/views/widget/user_post_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';

class UserPostsTabWidget extends StatelessWidget {
  final double topPadding; // To receive the estimated TabBar height

  const UserPostsTabWidget({super.key, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserDetailsBloc>().state;

    if (state.postsStatus == UserDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.postsStatus == UserDetailsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.errorMessage ??
                'Failed to load posts. Please try refreshing.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state.posts.isEmpty) {
      return const Center(child: Text('No posts found for this user.'));
    }

    return ListView.builder(
      // Apply padding: topPadding for the TabBar, +8.0 for general list padding
      padding: EdgeInsets.fromLTRB(8.0, topPadding + 8.0, 8.0, 8.0),
      // physics: AlwaysScrollableScrollPhysics(), // Add for testing if needed
      itemCount: state.posts.length, // Or 50 for testing scrollability
      itemBuilder: (context, index) {
        // FOR TESTING with 50 items:
        // if (state.posts.isEmpty) {
        //   return Card(child: ListTile(title: Text('Test Post Item ${index + 1} for padding')));
        // }
        // final post = state.posts[index % state.posts.length];
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Views: ${post.views}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.reactions.likes}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.thumb_down_alt_outlined,
                          size: 16,
                          color: Colors.red,
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children:
                        post.tags
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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
