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
  }

  Future<void> _onLocalPostEventLoad(
    LocalPostEventLoad event,
    Emitter<LocalPostState> emit,
  ) async {
    emit(state.copyWith(status: LocalPostStatus.loading));
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
    final updatePosts = List<LocalPostModel>.from(state.posts)
      ..insert(0, event.post);
    emit(state.copyWith(posts: updatePosts, status: LocalPostStatus.success));
  }
}
