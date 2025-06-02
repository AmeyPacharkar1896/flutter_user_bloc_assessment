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

  // Helper function for the onRefresh callback
  Future<void> _refreshUserDetails(
    BuildContext context,
    UserDetailsState currentState,
  ) async {
    // We need the current userId to refresh.
    // It's safest to get it from the current state's user object if available,
    // or from the UserDetailsView widget which holds the initial userId.
    int? userIdToRefresh = currentState.user?.id;

    if (userIdToRefresh == null) {
      // Fallback to get userId from the UserDetailsView widget if state.user is not yet loaded
      final detailsViewWidget =
          context.findAncestorWidgetOfExactType<UserDetailsView>();
      if (detailsViewWidget != null) {
        userIdToRefresh = detailsViewWidget.userId;
      }
    }

    if (userIdToRefresh != null) {
      context.read<UserDetailsBloc>().add(
        UserDetailsEventFetchAllDetails(
          userId: userIdToRefresh,
          initialUser:
              currentState
                  .user, // Pass current user to potentially reduce UI flicker
        ),
      );
    }
    // If userId cannot be determined, do nothing or complete the future immediately
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<UserDetailsBloc, UserDetailsState>(
        listener: (context, state) {
          // Your existing listener code (for SnackBars)
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
                  backgroundColor: theme.colorScheme.error,
                  action: SnackBarAction(
                    label: 'Retry All',
                    textColor: theme.colorScheme.onError,
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
          // Loading state for the entire screen if user data isn't available yet
          if (state.userState == UserDetailsStatus.loading &&
              state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Failure state if user data couldn't be loaded
          if (state.userState == UserDetailsStatus.failure &&
              state.user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ?? 'Failed to load user data.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final detailsViewWidget =
                            context
                                .findAncestorWidgetOfExactType<
                                  UserDetailsView
                                >();
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
              ),
            );
          }

          final user = state.user;
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.errorMessage ?? 'User data not available.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final appBarForegroundColor =
              theme.appBarTheme.foregroundColor ??
              (theme.colorScheme.primary.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white);

          return RefreshIndicator(
            onRefresh:
                () => _refreshUserDetails(context, state), // Use the helper
            child: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ), // Ensure scroll for refresh
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
                        pinned: true,
                        expandedHeight: 250.0,
                        forceElevated: innerBoxIsScrolled,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: appBarForegroundColor,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: UserInfoHeaderWidget(user: user),
                          collapseMode: CollapseMode.parallax,
                        ),
                        bottom: TabBar(
                          indicatorColor: appBarForegroundColor,
                          labelColor: appBarForegroundColor,
                          unselectedLabelColor: appBarForegroundColor
                              .withOpacity(0.7),
                          tabs: const [Tab(text: 'Posts'), Tab(text: 'Todos')],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _buildTabContent(
                      context,
                      const UserPostsTabWidget(),
                      'posts_key',
                    ),
                    _buildTabContent(
                      context,
                      const UserTodosTabWidget(),
                      'todos_key',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method from before - this correctly handles overlap
  Widget _buildTabContent(
    BuildContext context,
    Widget tabChild,
    String pageStorageKey,
  ) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: PageStorageKey<String>(pageStorageKey),
            // It's important that the inner scroll views also allow scrolling for the RefreshIndicator to work well.
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              SliverFillRemaining(hasScrollBody: true, child: tabChild),
            ],
          );
        },
      ),
    );
  }
}
