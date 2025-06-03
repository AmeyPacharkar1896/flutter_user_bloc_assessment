import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';
import 'package:flutter_user_bloc_assessment/modules/service/local_post_repository.dart';

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
    on<LocalPostEventClearMessages>(_onLocalPostEventClearMessages);
  }

  Future<void> _onLocalPostEventLoad(
    LocalPostEventLoad event,
    Emitter<LocalPostState> emit,
  ) async {
    final bool isInitialLoad = state.status == LocalPostStatus.initial;
    emit(
      state.copyWith(
        status: LocalPostStatus.loading,
        posts: isInitialLoad ? [] : state.posts,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final posts = await _localPostRepository.getLocalPosts();
      log('[LocalPostsBloc] Loaded ${posts.length} local posts.');
      emit(
        state.copyWith(
          status: LocalPostStatus.success,
          posts: posts,
          errorMessage: null,
          successMessage: null,
        ),
      );
    } catch (e) {
      log('[LocalPostsBloc] Error loading local posts: $e');
      emit(
        state.copyWith(
          status: LocalPostStatus.failure,
          errorMessage: "Failed to load posts: ${e.toString()}",
          successMessage: null,
        ),
      );
    }
  }

  FutureOr<void> _onLocalPostEventAdd(
    LocalPostEventAdd event,
    Emitter<LocalPostState> emit,
  ) {
    final updatedPosts = List<LocalPostModel>.from(state.posts)
      ..insert(0, event.post);
    log('[LocalPostBloc] Optimistically added post: ${event.post.title}');
    emit(
      state.copyWith(
        posts: updatedPosts,
        status: LocalPostStatus.success,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  Future<void> _onLocalPostEventDelete(
    LocalPostEventDelete event,
    Emitter<LocalPostState> emit,
  ) async {
    final postToDelete = state.posts.firstWhere(
      (p) => p.id == event.postId,
      orElse: () => const LocalPostModel(id: -1, title: "Unknown", body: ""),
    );
    final String deletedPostTitle =
        postToDelete.id != -1 ? postToDelete.title : "Post";

    final optimisticPosts = List<LocalPostModel>.from(state.posts)
      ..removeWhere((post) => post.id == event.postId);

    emit(
      state.copyWith(
        posts: optimisticPosts,
        status: LocalPostStatus.success,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _localPostRepository.deletePost(event.postId);
      log(
        '[LocalPostsBloc] Successfully deleted post with ID: ${event.postId} from repository.',
      );
      emit(
        state.copyWith(
          status: LocalPostStatus.success,
          successMessage: '"$deletedPostTitle" deleted successfully.',
          errorMessage: null,
          // posts already updated optimistically
        ),
      );
    } catch (e) {
      log('[LocalPostsBloc] Error deleting post with ID ${event.postId}: $e');
      emit(
        state.copyWith(
          status: LocalPostStatus.failure,
          errorMessage: "Failed to delete post: ${e.toString()}",
          successMessage: null,
        ),
      );
      add(LocalPostEventLoad());
    }
  }

  void _onLocalPostEventClearMessages(
    LocalPostEventClearMessages event,
    Emitter<LocalPostState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
