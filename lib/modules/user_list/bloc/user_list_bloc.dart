import 'dart:async';
import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_user_bloc_assessment/core/api/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_user_bloc_assessment/core/models/user_model/user_model.dart';
import 'package:stream_transform/stream_transform.dart';

part 'user_list_state.dart';
part 'user_list_event.dart';

// Used to debounce search queries
EventTransformer<E> debounceDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.debounce(duration), mapper);
  };
}

const int _usersLimit = 20; // Number of users to fetch per page

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
    on<UserListFetchMoreUsers>(_onFetchMoreUsers);
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
          users: response!.users,
          hasReachedMax:
              response.users.length >=
              response
                  .total, // or response.users.isEmpty if API behaves that way
          currentQuery: null, // Clear any previous query
        ),
      );
    } catch (e) {
      log('Error in _onFetchUsers: $e');
      emit(UserListStateError('Failed to fetch users: ${e.toString()}'));
    }
  }

  Future<void> _onUserListSearchUsers(
    UserListSearchUsers event,
    Emitter<UserListState> emit,
  ) async {
    if (event.query.isEmpty) {
      // If query is empty, revert to fetching all users (or emit initial/empty loaded state)
      add(const UserListFetchUsers()); // This will reset to the full list
      return;
    }

    emit(UserListStateLoading()); // Show loading for a new search
    try {
      final response = await _userService.fetchUserList(
        query: event.query,
        limit: _usersLimit,
        skip: 0,
      );
      emit(
        UserListStateLoaded(
          users: response!.users,
          hasReachedMax: response.users.length >= response.total,
          currentQuery: event.query,
        ),
      );
    } catch (e) {
      log('Error in _onUserListSearchUsers: $e');
      emit(
        UserListStateError(
          'Failed to search users for "${event.query}": ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onFetchMoreUsers(
    UserListFetchMoreUsers event,
    Emitter<UserListState> emit,
  ) async {
    // Ensure we are in a loaded state and haven't reached the max
    if (state is UserListStateLoaded) {
      final currentState = state as UserListStateLoaded;
      if (currentState.hasReachedMax) return; // Do nothing if already at max
      try {
        final response = await _userService.fetchUserList(
          limit: _usersLimit,
          skip:
              currentState
                  .users
                  .length, // Calculate skip based on current count
          query: currentState.currentQuery, // Use current query for pagination
        );

        if (response!.users.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              users: List.of(currentState.users)..addAll(response.users),
              hasReachedMax:
                  (currentState.users.length + response.users.length) >=
                  response.total,
            ),
          );
        }
      } catch (e) {
        log('Error in _onFetchMoreUsers: $e');
        emit(UserListStateError('Failed to load more users: ${e.toString()}'));
      }
    }
  }
}
