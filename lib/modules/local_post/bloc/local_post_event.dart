part of 'local_post_bloc.dart';

abstract class LocalPostEvent extends Equatable {
  const LocalPostEvent();

  @override
  List<Object> get props => [];
}

class LocalPostEventLoad extends LocalPostEvent {}

class LocalPostEventAdd extends LocalPostEvent {
  final LocalPostModel post;

  const LocalPostEventAdd({required this.post});

  @override
  List<Object> get props => [post];
}

class LocalPostEventDelete extends LocalPostEvent {
  final int postId;

  const LocalPostEventDelete({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LocalPostEventClearMessages extends LocalPostEvent {}
