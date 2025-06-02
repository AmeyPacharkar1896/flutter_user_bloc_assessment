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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No separate Scaffold.appBar here, it's handled by SliverAppBar
      body: BlocConsumer<UserDetailsBloc, UserDetailsState>(
        listener: (context, state) {
          // Your listener code (for SnackBars)
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
                          context.findAncestorWidgetOfExactType<UserDetailsView>();
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
          if (state.userState == UserDetailsStatus.loading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Failure state if user data couldn't be loaded
          if (state.userState == UserDetailsStatus.failure && state.user == null) {
            return Center( /* ... your error retry UI ... */ );
          }

          final user = state.user;
          if (user == null) {
            return Center( /* ... your user data not available UI ... */ );
          }

          return DefaultTabController(
            length: 2, // Number of tabs
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverAppBar(
                      // No direct title here to avoid redundancy with UserInfoHeaderWidget when expanded
                      // title: Text(user.fullName), // REMOVE or use FlexibleSpaceBar.title
                      pinned: true, // Keeps the TabBar pinned
                      expandedHeight: 250.0, // Adjust this to fit your UserInfoHeaderWidget comfortably
                                             // May need to be smaller if UserInfoHeaderWidget is more compact
                      forceElevated: innerBoxIsScrolled,
                      leading: IconButton( // Explicitly add a back button
                        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary), // Ensure color contrasts with AppBar
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      flexibleSpace: FlexibleSpaceBar( // Typically false when there's a leading icon
                        background: UserInfoHeaderWidget(user: user),
                        collapseMode: CollapseMode.parallax, // Or .pin
                      ),
                      bottom: TabBar(
                        indicatorColor: Theme.of(context).colorScheme.onPrimary,
                        labelColor: Theme.of(context).colorScheme.onPrimary,
                        unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                        tabs: const [
                          Tab(text: 'Posts'), // Keep it simple, icons can make it taller
                          Tab(text: 'Todos'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: <Widget>[
                  _buildTabContent(context, const UserPostsTabWidget(), 'posts_key'),
                  _buildTabContent(context, const UserTodosTabWidget(), 'todos_key'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method from before - this correctly handles overlap
  Widget _buildTabContent(BuildContext context, Widget tabChild, String pageStorageKey) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: PageStorageKey<String>(pageStorageKey),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: tabChild,
              ),
            ],
          );
        },
      ),
    );
  }
}