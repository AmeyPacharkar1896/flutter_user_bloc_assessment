import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/user_details_view.dart'; // For retry logic
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_info_header_widget.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_post_tab_widget.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/widget/user_todo_tab_widget.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late ScrollController _scrollController;
  double _titleOpacity = 0.0;

  // Threshold at which the app bar title becomes fully opaque
  static const double _opacityThreshold = 150.0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final offset = _scrollController.offset;
    double newOpacity = (offset / _opacityThreshold).clamp(0.0, 1.0);

    if (newOpacity != _titleOpacity) {
      setState(() {
        _titleOpacity = newOpacity;
      });
    }
  }

  // Retry and refresh functions from your original code (unchanged)
  void _retryFetchAll(BuildContext context) {
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
  }

  Future<void> _refreshUserDetails(
    BuildContext context,
    UserDetailsState currentState,
  ) async {
    int? userIdToRefresh = currentState.user?.id;

    if (userIdToRefresh == null) {
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
          initialUser: currentState.user,
        ),
      );
    }
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color appBarActualBackgroundColor =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    final Color appBarForegroundColor =
        theme.appBarTheme.titleTextStyle?.color ??
        theme.appBarTheme.iconTheme?.color ??
        (appBarActualBackgroundColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white);

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
                  backgroundColor: theme.colorScheme.error,
                  action: SnackBarAction(
                    label: 'Retry All',
                    textColor: theme.colorScheme.onError,
                    onPressed: () => _retryFetchAll(context),
                  ),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.userState == UserDetailsStatus.loading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.userState == UserDetailsStatus.failure && state.user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Failed to load user data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _retryFetchAll(context),
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
                  state.errorMessage ?? 'User data not available. Please try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshUserDetails(context, state),
            child: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                controller: _scrollController, // <-- Attach controller here
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar(
                        backgroundColor: appBarActualBackgroundColor,
                        pinned: true,
                        expandedHeight: 280.0,
                        forceElevated: innerBoxIsScrolled,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: appBarForegroundColor,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),

                        // Use AnimatedOpacity to fade the title based on scroll
                        title: AnimatedOpacity(
                          opacity: _titleOpacity,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            user.fullName,
                            style: TextStyle(color: appBarForegroundColor),
                          ),
                        ),

                        flexibleSpace: FlexibleSpaceBar(
                          background: UserInfoHeaderWidget(user: user),
                          collapseMode: CollapseMode.parallax,
                          titlePadding: EdgeInsets.zero,
                          title: const SizedBox.shrink(), // No title here, it's in app bar
                        ),

                        bottom: TabBar(
                          indicatorColor: appBarForegroundColor,
                          labelColor: appBarForegroundColor,
                          unselectedLabelColor: appBarForegroundColor.withAlpha((0.5 * 255).toInt()),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                          tabs: const [
                            Tab(text: 'Posts'),
                            Tab(text: 'Todos'),
                          ],
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
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverFillRemaining(hasScrollBody: true, child: tabChild),
            ],
          );
        },
      ),
    );
  }
}
