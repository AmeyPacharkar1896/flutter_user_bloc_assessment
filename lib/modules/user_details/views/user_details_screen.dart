// file: lib/modules/user_details/views/user_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/user_details_view.dart'; // For retry logic
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_info_header_widget.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_post_tab_widget.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_todo_tab_widget.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});
  static const double tabBarEstimatedHeight = 5.0; // Default for icon and text tabs by Material Design spec.

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocConsumer<UserDetailsBloc, UserDetailsState>(
        listener: (context, state) {
          // Your listener code (keep as is)
          if (state.errorMessage != null &&
              (state.postsStatus == UserDetailsStatus.failure ||
                  state.todosStatus == UserDetailsStatus.failure ||
                  (state.userState == UserDetailsStatus.failure &&
                      state.user == null))) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  action: SnackBarAction(
                    label: 'Retry All',
                    onPressed: () {
                      final detailsViewWidget =
                          context
                              .findAncestorWidgetOfExactType<UserDetailsView>();
                      if (detailsViewWidget != null) {
                        context.read<UserDetailsBloc>().add(
                          UserDetailsEventFetchAllDetails(
                            userId: detailsViewWidget.userId,
                            initialUser: detailsViewWidget.initialUser,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
          }
        },
        builder: (context, state) {
          // Your loading and error handling for the main user (keep as is)
          if (state.userState == UserDetailsStatus.loading &&
              state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.userState == UserDetailsStatus.failure &&
              state.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load user data.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final detailsViewWidget =
                          context
                              .findAncestorWidgetOfExactType<UserDetailsView>();
                      if (detailsViewWidget != null) {
                        context.read<UserDetailsBloc>().add(
                          UserDetailsEventFetchAllDetails(
                            userId: detailsViewWidget.userId,
                            initialUser: detailsViewWidget.initialUser,
                          ),
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = state.user;
          if (user == null) {
            return Center(
              child: Text(state.errorMessage ?? 'User data not available.'),
            );
          }

          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (
                BuildContext context,
                bool innerBoxIsScrolled,
              ) {
                return <Widget>[
                  // No SliverOverlapAbsorber
                  SliverAppBar(
                    title: Text(user.fullName),
                    pinned: true,
                    expandedHeight: 300.0,
                    forceElevated: innerBoxIsScrolled,
                    flexibleSpace: FlexibleSpaceBar(
                      background: UserInfoHeaderWidget(user: user),
                      collapseMode: CollapseMode.parallax,
                    ),
                    bottom: TabBar(
                      // This TabBar's height needs to be accounted for
                      indicatorColor: Theme.of(context).colorScheme.onPrimary,
                      labelColor: Theme.of(context).colorScheme.onPrimary,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.7),
                      tabs: const [
                        Tab(icon: Icon(Icons.article_outlined), text: 'Posts'),
                        Tab(
                          icon: Icon(Icons.checklist_rtl_outlined),
                          text: 'Todos',
                        ),
                      ],
                    ),
                  ),
                ];
              },
              // The body's children are now simpler, padding handled internally by tab widgets
              body: const TabBarView(
                children: <Widget>[
                  UserPostsTabWidget(topPadding: tabBarEstimatedHeight),
                  UserTodosTabWidget(topPadding: tabBarEstimatedHeight),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
