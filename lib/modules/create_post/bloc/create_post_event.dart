part of 'create_post_bloc.dart';

abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object> get props => [];
}

class CreatePostEventSubmitLocalPost extends CreatePostEvent {
  final String title;
  final String body;

  const CreatePostEventSubmitLocalPost({
    required this.title,
    required this.body,
  });

  @override
  List<Object> get props => [title, body];
}
