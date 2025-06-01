part of 'user_list_bloc.dart';

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object?> get props => [];
}

class UserListStateInitial extends UserListState {}

class UserListStateLoading extends UserListState {}

class UserListStateLoaded extends UserListState {
  final List<User> users;
  final bool hasReachedMax;
  final String? currentQuery;

  const UserListStateLoaded({
    required this.users,
    this.hasReachedMax = false,
    this.currentQuery,
  });

  UserListStateLoaded copyWith({
    List<User>? users,
    bool? hasReachedMax,
    String? currentQuery,
    bool clearQuery = false,
  }) {
    return UserListStateLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentQuery: clearQuery ? null : (currentQuery ?? this.currentQuery),
    );
  }

  @override
  List<Object?> get props => [users, hasReachedMax, currentQuery];
}

class UserListStateError extends UserListState {
  final String message;

  const UserListStateError(this.message);

  @override
  List<Object> get props => [message];
}
