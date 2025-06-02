part of 'local_post_bloc.dart';

enum LocalPostStatus { initial, loading, success, failure }

class LocalPostState extends Equatable {
  final LocalPostStatus status;
  final List<LocalPostModel> posts;
  final String? errorMessage;

  const LocalPostState({
    this.status = LocalPostStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  LocalPostState copyWith({
    LocalPostStatus? status,
    List<LocalPostModel>? posts,
    String? errorMessage,
  }) {
    return LocalPostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, posts, errorMessage];
}
