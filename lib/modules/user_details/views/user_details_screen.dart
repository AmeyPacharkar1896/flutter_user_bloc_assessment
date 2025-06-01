import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/user_details_view.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_info_header_widget.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_post_tab_widget.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_todo_tab_widget.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserDetailsBloc, UserDetailsState>(
        listener: (context, state) {
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
                      final screenWidget =
                          context
                              .findAncestorWidgetOfExactType<UserDetailsView>();
                      if (screenWidget != null) {
                        context.read<UserDetailsBloc>().add(
                          UserDetailsEventFetchAllDetails(
                            userId: screenWidget.userId,
                            initialUser: screenWidget.initialUser,
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
          // Initial loading state for the user object itself
          if (state.userState == UserDetailsStatus.loading &&
              state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Failure to load the main user object
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
                      final screenWidget =
                          context
                              .findAncestorWidgetOfExactType<UserDetailsView>();
                      if (screenWidget != null) {
                        context.read<UserDetailsBloc>().add(
                          UserDetailsEventFetchAllDetails(
                            userId: screenWidget.userId,
                            initialUser: screenWidget.initialUser,
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

          // If user data is available (either initial or fetched successfully)
          final user = state.user;

          // If user is null even after attempting load (should be covered by above), show error.
          if (user == null) {
            return Center(
              child: Text(state.errorMessage ?? 'User data not available.'),
            );
          }

          return DefaultTabController(
            length: 2, // For Posts and Todos
            child: NestedScrollView(
              headerSliverBuilder: (
                BuildContext context,
                bool innerBoxIsScrolled,
              ) {
                return <Widget>[
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: SliverAppBar(
                      title: Text(user.fullName), // App bar title
                      pinned: true,
                      expandedHeight: 300.0, // Adjusted height for more info
                      forceElevated: innerBoxIsScrolled,
                      flexibleSpace: FlexibleSpaceBar(
                        // title: Text(user.firstName, style: TextStyle(color: Colors.white)), // Optional title in flex space
                        background: UserInfoHeaderWidget(
                          user: user,
                        ), // Use the new widget
                        collapseMode: CollapseMode.parallax,
                      ),
                      bottom: const TabBar(
                        tabs: [
                          Tab(
                            icon: Icon(Icons.article_outlined),
                            text: 'Posts',
                          ), // Updated icons
                          Tab(
                            icon: Icon(Icons.checklist_rtl_outlined),
                            text: 'Todos',
                          ), // Updated icons
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: const TabBarView(
                children: [
                  // Provide BLoC context if needed by tabs, or they can use context.watch
                  UserPostsTabWidget(),
                  UserTodosTabWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
