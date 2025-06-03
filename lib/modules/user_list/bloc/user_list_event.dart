part of 'user_list_bloc.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

class UserListFetchUsers extends UserListEvent {
  final bool isRefresh;

  const UserListFetchUsers({this.isRefresh = false});
}

class UserListFetchMoreUsers extends UserListEvent {}

class UserListSearchUsers extends UserListEvent {
  final String query;

  const UserListSearchUsers(this.query);

  @override
  List<Object> get props => [query];
}
