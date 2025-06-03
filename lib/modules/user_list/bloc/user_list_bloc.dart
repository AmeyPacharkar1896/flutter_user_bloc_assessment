import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_user_bloc_assessment/core/service/user_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart';
import 'package:stream_transform/stream_transform.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

const int _usersLimit = 20;

/// Debounce search events while also making them droppable (skip intermediate values).
EventTransformer<E> debounceDroppable<E>(Duration duration) {
  return (events, mapper) =>
      droppable<E>().call(events.debounce(duration), mapper);
}

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserService _userService;

  UserListBloc({required UserService userService})
    : _userService = userService,
      super(UserListStateInitial()) {
    on<UserListFetchUsers>(_onUserListFetchUsers);
    on<UserListSearchUsers>(
      _onUserListSearchUsers,
      transformer: debounceDroppable(const Duration(milliseconds: 500)),
    );
    on<UserListFetchMoreUsers>(_onUserListFetchMoreUsers);
  }

  Future<void> _onUserListFetchUsers(
    UserListFetchUsers event,
    Emitter<UserListState> emit,
  ) async {
    emit(UserListStateLoading());
    try {
      final response = await _userService.fetchUserList(
        limit: _usersLimit,
        skip: 0,
      );
      emit(
        UserListStateLoaded(
          users: response.users,
          hasReachedMax: response.users.length >= response.total,
        ),
      );
    } catch (e) {
      emit(UserListStateError('Failed to fetch users: ${e.toString()}'));
    }
  }

  Future<void> _onUserListSearchUsers(
    UserListSearchUsers event,
    Emitter<UserListState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const UserListFetchUsers());
      return;
    }

    emit(UserListStateLoading());
    try {
      final response = await _userService.fetchUserList(
        query: event.query,
        limit: _usersLimit,
        skip: 0,
      );
      emit(
        UserListStateLoaded(
          users: response.users,
          hasReachedMax: response.users.length >= response.total,
          currentQuery: event.query,
        ),
      );
    } catch (e) {
      emit(UserListStateError('Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onUserListFetchMoreUsers(
    UserListFetchMoreUsers event,
    Emitter<UserListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserListStateLoaded || currentState.hasReachedMax)
      return;

    try {
      final response = await _userService.fetchUserList(
        limit: _usersLimit,
        skip: currentState.users.length,
        query: currentState.currentQuery,
      );

      final newUsers = response.users;
      emit(
        currentState.copyWith(
          users: List.of(currentState.users)..addAll(newUsers),
          hasReachedMax:
              (currentState.users.length + newUsers.length) >= response.total,
        ),
      );
    } catch (e) {
      emit(UserListStateError('Failed to load more users: ${e.toString()}'));
    }
  }
}
