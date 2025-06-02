// file: lib/modules/local_posts/bloc/local_post_bloc.dart
import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';
import 'package:flutter_user_bloc_assessment/modules/service/local_post_repository.dart'; // Corrected path

part 'local_post_event.dart';
part 'local_post_state.dart';

class LocalPostBloc extends Bloc<LocalPostEvent, LocalPostState> {
  final LocalPostRepository _localPostRepository;

  LocalPostBloc({required LocalPostRepository localPostRepository})
    : _localPostRepository = localPostRepository,
      super(const LocalPostState()) {
    on<LocalPostEventLoad>(_onLocalPostEventLoad);
    on<LocalPostEventAdd>(_onLocalPostEventAdd);
    on<LocalPostEventDelete>(_onLocalPostEventDelete);
  }

  Future<void> _onLocalPostEventLoad(
    LocalPostEventLoad event,
    Emitter<LocalPostState> emit,
  ) async {
    // Keep existing posts during refresh if not initial load
    final bool isInitialLoad = state.status == LocalPostStatus.initial;
    emit(
      state.copyWith(
        status: LocalPostStatus.loading,
        posts: isInitialLoad ? [] : state.posts,
      ),
    );
    try {
      final posts = await _localPostRepository.getLocalPosts();
      log('[LocalPostsBloc] Loaded ${posts.length} local posts.');
      emit(state.copyWith(status: LocalPostStatus.success, posts: posts));
    } catch (e) {
      log('[LocalPostsBloc] Error loading local posts: $e');
      emit(
        state.copyWith(
          status: LocalPostStatus.failure,
          errorMessage: "Failed to load posts: ${e.toString()}",
        ),
      );
    }
  }

  FutureOr<void> _onLocalPostEventAdd(
    LocalPostEventAdd event,
    Emitter<LocalPostState> emit,
  ) {
    // Optimistically update by adding the new post (which should have its ID from the repo)
    final updatedPosts = List<LocalPostModel>.from(state.posts)
      ..insert(0, event.post); // Insert at the beginning to show newest first
    log('[LocalPostBloc] Optimistically added post: ${event.post.title}');
    emit(state.copyWith(posts: updatedPosts, status: LocalPostStatus.success));
  }

  Future<void> _onLocalPostEventDelete(
    LocalPostEventDelete event,
    Emitter<LocalPostState> emit,
  ) async {
    // Optimistic UI Update
    final postToDelete = state.posts.firstWhere(
      (p) => p.id == event.postId,
      orElse: () => const LocalPostModel(id: -1, title: "Unknown", body: ""),
    ); // Find post title for message
    final String deletedPostTitle =
        postToDelete.id != -1 ? postToDelete.title : "Post";

    final optimisticPosts = List<LocalPostModel>.from(state.posts)
      ..removeWhere((post) => post.id == event.postId);

    // Emit current posts but maybe a 'deleting' status or just keep success from previous load
    // For snackbar, we need a distinct state change or message after successful repo call
    emit(
      state.copyWith(posts: optimisticPosts, status: LocalPostStatus.success),
    ); // Clear previous messages

    try {
      await _localPostRepository.deletePost(event.postId);
      log(
        '[LocalPostsBloc] Successfully deleted post with ID: ${event.postId} from repository.',
      );

      // **** EMIT STATE WITH SUCCESS MESSAGE FOR SNACKBAR ****
      // The list is already updated optimistically.
      // We emit again with a success message.
      emit(
        state.copyWith(
          status: LocalPostStatus.success, // Still success
          // posts: optimisticPosts, // Already set
          successMessage: '"$deletedPostTitle" deleted successfully.',
        ),
      );
    } catch (e) {
      log('[LocalPostsBloc] Error deleting post with ID ${event.postId}: $e');
      // Revert optimistic update is hard without storing original list, so reloading is safer on error.
      emit(
        state.copyWith(
          status: LocalPostStatus.failure,
          errorMessage: "Failed to delete post: ${e.toString()}",
        ),
      );
      // Reload the list from the source to ensure consistency after a delete error
      add(LocalPostEventLoad());
    }
  }
}
