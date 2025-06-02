// file: lib/modules/local_posts/bloc/local_post_event.dart
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

// **** NEW EVENT FOR DELETING A POST ****
class LocalPostEventDelete extends LocalPostEvent {
  final int postId; // ID of the post to delete

  const LocalPostEventDelete({required this.postId});

  @override
  List<Object> get props => [postId];
}
