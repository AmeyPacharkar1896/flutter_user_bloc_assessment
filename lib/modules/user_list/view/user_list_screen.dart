// lib/modules/user_list/view/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_controller.dart';

import '../bloc/user_list_bloc.dart';
import '../model/user_model.dart';
import '../../user_details/views/user_details_view.dart';

import 'widgets/uesr_list_searchbar.dart';
import 'widgets/user_list_item.dart';
import 'widgets/user_list_loading.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final UserListController _controller;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _searchController = TextEditingController();

    _controller = UserListController(
      scrollController: _scrollController,
      searchController: _searchController,
      context: context,
    );

    _controller.showToTopButton.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToUserDetail(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserDetailsView(userId: user.id, initialUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            UserListSearchBar(controller: _searchController),
            Expanded(
              child: BlocBuilder<UserListBloc, UserListState>(
                builder: (context, state) {
                  if (state is UserListStateInitial) {
                    return const Center(child: Text("Initializing users..."));
                  }

                  if (state is UserListStateLoading) {
                    return const UserListLoadingIndicator();
                  }

                  if (state is UserListStateError) {
                    return UserListErrorView(
                      message: state.message,
                      onRetry: () {
                        _searchController.clear();
                        context.read<UserListBloc>().add(
                              const UserListFetchUsers(),
                            );
                      },
                    );
                  }

                  if (state is UserListStateLoaded) {
                    final users = state.users;
                    final hasReachedMax = state.hasReachedMax;
                    final isLoadingMore = state is UserListStateLoading;

                    if (users.isEmpty && !isLoadingMore) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            (state.currentQuery != null &&
                                    state.currentQuery!.isNotEmpty)
                                ? 'No users found for "${state.currentQuery}".\nClear search.'
                                : 'No users available.\nPull down to refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _controller.handleRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: (hasReachedMax && !isLoadingMore)
                            ? users.length
                            : users.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= users.length) {
                            return (!hasReachedMax)
                                ? const UserListLoadingIndicator(
                                    margin: EdgeInsets.symmetric(vertical: 16),
                                  )
                                : const SizedBox.shrink();
                          }
                          final user = users[index];
                          return UserListItem(
                            user: user,
                            onTap: () => _navigateToUserDetail(user),
                          );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      'Something went wrong. Please check your connection.',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        if (_controller.showToTopButton.value)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _controller.scrollToTop,
              tooltip: 'Scroll to top',
              child: const Icon(Icons.arrow_upward, size: 20),
            ),
          ),
      ],
    );
  }
}
