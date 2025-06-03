import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';
import 'package:flutter_user_bloc_assessment/core/service/local_post_repository.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final LocalPostRepository _localPostRepository;

  CreatePostBloc({required LocalPostRepository localPostRepository})
    : _localPostRepository = localPostRepository,
      super(CreatePostStateInitial()) {
    on<CreatePostEventSubmitLocalPost>(_onCreatePostEventSubmitLocalPost);
  }

  Future<void> _onCreatePostEventSubmitLocalPost(
    CreatePostEventSubmitLocalPost event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(CreatePostStateLoading());

    // Basic validation
    if (event.title.trim().isEmpty) {
      emit(const CreatePostStateFailure(error: "Title cannot be empty."));
      return;
    }
    if (event.body.trim().isEmpty) {
      emit(const CreatePostStateFailure(error: "Body cannot be empty."));
      return;
    }

    try {
      final newPostData = LocalPostModel(
        id: 0,
        title: event.title,
        body: event.body,
      );

      final savedPost = await _localPostRepository.addPost(newPostData);
      log("[CreatePostBloc] Post submitted and saved: ${savedPost.title}");

      emit(CreatePostStateSuccess(post: savedPost));
    } catch (e) {
      log('[CreatePostBloc] Error submitting post: $e');
      emit(
        CreatePostStateFailure(error: "Failed to save post: ${e.toString()}"),
      );
    }
  }
}
