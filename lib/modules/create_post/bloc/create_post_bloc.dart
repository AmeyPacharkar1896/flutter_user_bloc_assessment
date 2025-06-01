import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  CreatePostBloc() : super(CreatePostStateInitial()) {
    on<CreatePostEventSubmitLocalPost>(_onCreatePostEventSubmitLocalPost);
  }

  List<LocalPostModel> _localPosts = [];
  List<LocalPostModel> get localPosts => _localPosts;

  FutureOr<void> _onCreatePostEventSubmitLocalPost(
    CreatePostEventSubmitLocalPost event,
    Emitter<CreatePostState> emit,
  ) {
    emit(CreatePostStateLoading());

    try {
      final newPost = LocalPostModel(
        id: _localPosts.length + 1,
        title: event.title,
        body: event.body,
      );

      _localPosts.add(newPost);
      emit(CreatePostStateSuccess(post: newPost));
    } catch (e) {
      emit(CreatePostStateFailure(error: e.toString()));
    }
  }
}
