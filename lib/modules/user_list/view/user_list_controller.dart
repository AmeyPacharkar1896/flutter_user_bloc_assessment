// lib/modules/user_list/controller/user_list_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_list_bloc.dart';

class UserListController {
  final ScrollController scrollController;
  final TextEditingController searchController;
  final BuildContext context;
  final ValueNotifier<bool> showToTopButton = ValueNotifier(false);

  UserListController({
    required this.scrollController,
    required this.searchController,
    required this.context,
  }) {
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    return currentScroll >= (maxScroll - 200);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final offset = scrollController.offset;

    if (offset >= 400 && !showToTopButton.value) {
      showToTopButton.value = true;
    } else if (offset < 400 && showToTopButton.value) {
      showToTopButton.value = false;
    }

    if (_isBottom) {
      final state = context.read<UserListBloc>().state;
      if (state is UserListStateLoaded && !state.hasReachedMax) {
        context.read<UserListBloc>().add(UserListFetchMoreUsers());
      }
    }
  }

  void _onSearchChanged() {
    context.read<UserListBloc>().add(
      UserListSearchUsers(searchController.text),
    );
  }

  Future<void> handleRefresh() async {
    if (searchController.text.isNotEmpty) {
      searchController.clear();
    } else {
      context.read<UserListBloc>().add(
        const UserListFetchUsers(isRefresh: true),
      );
    }
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
    searchController.removeListener(_onSearchChanged);
    showToTopButton.dispose();
  }
}
