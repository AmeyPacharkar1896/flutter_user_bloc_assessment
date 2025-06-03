// file: lib/modules/user_list/view/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart'; // Your User model
import 'package:flutter_user_bloc_assessment/modules/user_details/views/user_details_view.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/bloc/user_list_bloc.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  // **** RESTORED _isBottom GETTER ****
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Threshold for triggering load, e.g., 200 pixels from the bottom
    return currentScroll >= (maxScroll - 200.0);
  }

  void _onScroll() {
    // For "to top" button visibility
    if (_scrollController.hasClients) {
      if (_scrollController.offset >= 400 && !_showToTopButton) {
        if (mounted) {
          setState(() {
            _showToTopButton = true;
          });
        }
      } else if (_scrollController.offset < 400 && _showToTopButton) {
        if (mounted) {
          setState(() {
            _showToTopButton = false;
          });
        }
      }
    }

    // For infinite scroll - USES _isBottom
    if (_isBottom) {
      final currentState = context.read<UserListBloc>().state;
      if (currentState is UserListStateLoaded && !currentState.hasReachedMax) {
        context.read<UserListBloc>().add(UserListFetchMoreUsers());
      }
    }
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {}); // To update clear button visibility
    }
    context.read<UserListBloc>().add(
      UserListSearchUsers(_searchController.text),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // **** ENSURE _handleRefresh RETURNS A FUTURE ****
  Future<void> _handleRefresh() async {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
    } else {
      context.read<UserListBloc>().add(
        const UserListFetchUsers(isRefresh: true),
      );
    }
    ;
  }

  void _navigateToUserDetail(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserDetailsView(userId: user.id, initialUser: user),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search User by name',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              // _onSearchChanged is called by listener, which dispatches SearchUsers('')
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).inputDecorationTheme.fillColor ??
                      Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<UserListBloc, UserListState>(
                builder: (context, state) {
                  if (state is UserListStateInitial) {
                    return const Center(child: Text("Initializing users..."));
                  }

                  // Show full screen loader only if it's the initial load and users list is empty
                  if (state is UserListStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UserListStateError) {
                    return Center(
                      child: Padding(
                        // Added padding for error message
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<UserListBloc>().add(
                                  const UserListFetchUsers(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Handle UserListStateLoaded and UserListStateLoading (when users list is not empty - i.e., loading more)
                  if (state is UserListStateLoaded) {
                    final users = state.users;
                    final bool isLoadingMore =
                        state
                            is UserListStateLoading; // Simpler check for loading more indicator
                    final bool hasReachedMax = state.hasReachedMax;

                    if (users.isEmpty && !isLoadingMore) {
                      return Center(
                        child: Padding(
                          // Added padding for empty message
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            (state.currentQuery != null &&
                                    state.currentQuery!.isNotEmpty)
                                ? 'No users found for "${state.currentQuery}".\nClear search.'
                                : 'No users available.\nPull down to refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            (hasReachedMax && !isLoadingMore)
                                ? users.length
                                : users.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= users.length) {
                            return (isLoadingMore ||
                                    !hasReachedMax) // Show if loading more OR if not reached max (initial passes)
                                ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }
                          final user = users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ), // Adjusted margins
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              leading: ClipOval(
                                child: Image.network(
                                  user.image,
                                  width: 48, // Slightly larger avatar
                                  height: 48,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.person_outline,
                                        color: Colors.grey[600],
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                user.email,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                              onTap: () => _navigateToUserDetail(user),
                            ),
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
        if (_showToTopButton)
          Positioned(
            bottom: 16, // Adjusted position
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _scrollToTop,
              child: const Icon(
                Icons.arrow_upward,
                size: 20,
              ), // Adjusted icon size
              tooltip: 'Scroll to top',
            ),
          ),
      ],
    );
  }
}
