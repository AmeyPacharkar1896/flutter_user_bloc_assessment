part of 'user_list_bloc.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch the initial list or refresh
class UserListFetchUsers extends UserListEvent {
  final bool isRefresh;
  const UserListFetchUsers({this.isRefresh = false});
}

// Event to fetch more users for pagination
class UserListFetchMoreUsers extends UserListEvent {}

// Event to search users
class UserListSearchUsers extends UserListEvent {
  final String query;

  const UserListSearchUsers(this.query);

  @override
  List<Object> get props => [query];
}
