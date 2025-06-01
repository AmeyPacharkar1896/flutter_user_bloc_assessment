part of 'user_details_bloc.dart';

enum UserDetailsStatus { initial, loading, success, failure }

class UserDetailsState extends Equatable {
  final UserDetailsStatus userState;
  final UserDetailsStatus postsStatus;
  final UserDetailsStatus todosStatus;
  final User? user;
  final List<Post> posts;
  final List<Todo> todos;
  final String? errorMessage;

  const UserDetailsState({
    this.userState = UserDetailsStatus.initial,
    this.postsStatus = UserDetailsStatus.initial,
    this.todosStatus = UserDetailsStatus.initial,
    this.user,
    this.posts = const [],
    this.todos = const [],
    this.errorMessage,
  });

  UserDetailsState copyWith({
    UserDetailsStatus? userState,
    UserDetailsStatus? postsStatus,
    UserDetailsStatus? todosStatus,
    User? user,
    List<Post>? posts,
    List<Todo>? todos,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return UserDetailsState(
      userState: userState ?? this.userState,
      postsStatus: postsStatus ?? this.postsStatus,
      todosStatus: todosStatus ?? this.todosStatus,
      user: user ?? this.user,
      posts: posts ?? this.posts,
      todos: todos ?? this.todos,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    userState,
    todosStatus,
    postsStatus,
    user,
    posts,
    todos,
    errorMessage,
  ];
}
