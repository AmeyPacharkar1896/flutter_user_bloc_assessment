// file: lib/modules/user_list/view/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart'; // Your User model
// Remove CreatePostView import if navigation is handled by parent
// import 'package:flutter_user_bloc_assessment/modules/create_post/view/create_post_view.dart';
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

  @override
  void initState() {
    super.initState();
    // UserListBloc is now provided by MainScreenWrapper, no need to add event here
    // if it's added on Bloc creation in MainScreenWrapper.
    // context.read<UserListBloc>().add(UserListFetchUsers()); // This might be redundant
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChange);
  }

  @override
  Widget build(BuildContext context) {
    // No Scaffold or AppBar here, as MainScreenWrapper handles it
    return Column(
      // The content of the "Users" tab
      children: [
        //search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search User by name',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200], // Example background for search
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
              ),
            ),
          ),
        ),
        //User list
        Expanded(
          child: BlocBuilder<UserListBloc, UserListState>(
            // Reads UserListBloc from MainScreenWrapper
            builder: (context, state) {
              // Your existing BlocBuilder logic for UserListStateInitial, Loading, Error, Loaded
              // This part can remain largely the same.
              if (state is UserListStateInitial) {
                return const Center(child: Text("Initializing users..."));
              }
              if (state is UserListStateLoading) {
                // Simplified loading check
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserListStateError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 10),
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
                );
              }
              if (state is UserListStateLoaded) {
                // Handle both loaded and loading-more states
                final users = state.users;

                final hasReachedMax = state.hasReachedMax;
                final currentQuery = state.currentQuery;

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      currentQuery != null && currentQuery.isNotEmpty
                          ? 'No users found for "$currentQuery".'
                          : 'No users available.',
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<UserListBloc>().add(
                      const UserListFetchUsers(isRefresh: true),
                    );
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: hasReachedMax ? users.length : users.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= users.length) {
                        return !hasReachedMax
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                            : const SizedBox.shrink();
                      }
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.image),
                            onBackgroundImageError:
                                (_, __) {}, // Placeholder for error
                            child:
                                user.image.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                          ),
                          title: Text(user.fullName),
                          subtitle: Text(user.email),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _navigateToUserDetail(user),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(child: Text('Something went wrong.'));
            },
          ),
        ),
      ],
    );
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll - 200.0);
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<UserListBloc>().state;
      if (currentState is UserListStateLoaded && !currentState.hasReachedMax) {
        context.read<UserListBloc>().add(UserListFetchMoreUsers());
      }
    }
  }

  void _onSearchChange() {
    context.read<UserListBloc>().add(
      UserListSearchUsers(_searchController.text),
    );
  }

  void _navigateToUserDetail(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserDetailsView(userId: user.id, initialUser: user),
      ),
    );
  }

  // _navigateToCreatePost is now handled by MainScreenWrapper's AppBar
  // void _navigateToCreatePost() { ... }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChange);
    _searchController.dispose();
    super.dispose();
  }
}
