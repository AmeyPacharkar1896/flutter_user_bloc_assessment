part of 'create_post_bloc.dart';

abstract class CreatePostState extends Equatable {
  const CreatePostState();
}

class CreatePostStateInitial extends CreatePostState {
  @override
  List<Object> get props => [];
}

class CreatePostStateLoading extends CreatePostState {
  @override
  List<Object> get props => [];
}

class CreatePostStateSuccess extends CreatePostState {
  final LocalPostModel post;

  const CreatePostStateSuccess({required this.post});

  @override
  List<Object> get props => [post];
}

class CreatePostStateFailure extends CreatePostState {
  final String error;

  const CreatePostStateFailure({required this.error});

  @override
  List<Object> get props => [error];
}
