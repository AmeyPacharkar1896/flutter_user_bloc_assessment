import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/core/models/user_model/user_model.dart';
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
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            onPressed: _navigateToCreatePost,
            icon: Icon(Icons.add_circle_outline),
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: Column(
        children: [
          //search bar
          Padding(
            padding: EdgeInsets.all(8.0),
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
              builder: (context, state) {
                if (state is UserListStateInitial) {
                  return const Center(child: Text("Initializing..."));
                }
                if (state is UserListStateLoading &&
                    ((BlocProvider.of<UserListBloc>(context).state
                            is! UserListStateLoaded) ||
                        (BlocProvider.of<UserListBloc>(context).state
                                as UserListStateLoaded)
                            .users
                            .isEmpty)) {
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
                            _searchController.clear(); // Clear search bar

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
                  if (state.users.isEmpty) {
                    return Center(
                      child: Text(
                        state.currentQuery != null &&
                                state.currentQuery!.isNotEmpty
                            ? 'No users found for "${state.currentQuery}".'
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
                      itemCount:
                          state.hasReachedMax
                              ? state.users.length
                              : state.users.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.users.length) {
                          return !state.hasReachedMax
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }

                        //actual user list
                        final user = state.users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.image),
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
                // Fallback for any unhandled state (shouldn't ideally happen)
                return const Center(
                  child: Text('Something went wrong. Please try again.'),
                );
              },
            ),
          ),
        ],
      ),
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
      final currenState = context.read<UserListBloc>().state;
      if (currenState is UserListStateLoaded && !currenState.hasReachedMax) {
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

  void _navigateToCreatePost() {
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (_) => const CreatePostScreen(),
    // ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to create post screen')),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController
      ..removeListener(_onSearchChange)
      ..dispose();
    super.dispose();
  }
}
