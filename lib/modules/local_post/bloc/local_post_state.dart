part of 'local_post_bloc.dart';

enum LocalPostStatus { initial, loading, success, failure }

class LocalPostState extends Equatable {
  final LocalPostStatus status;
  final List<LocalPostModel> posts;
  final String? errorMessage;
  final String? successMessage;

  const LocalPostState({
    this.status = LocalPostStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.successMessage,
  });

  LocalPostState copyWith({
    LocalPostStatus? status,
    List<LocalPostModel>? posts,
    String? errorMessage,
    String? successMessage,
  }) {
    return LocalPostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, posts, errorMessage, successMessage];
}
