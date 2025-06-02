import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/post_models/post_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/post_models/post_model.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/todo_models/todo_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/todo_models/todo_model.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart';
import 'package:flutter_user_bloc_assessment/modules/service/user_service.dart';

part 'user_details_event.dart';
part 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  final UserService _userService;

  UserDetailsBloc({required UserService userService})
    : _userService = userService,
      super(const UserDetailsState()) {
    on<UserDetailsEventFetchAllDetails>(_onUserDetailsEventFetchAllDetails);
  }

  Future<void> _onUserDetailsEventFetchAllDetails(
    UserDetailsEventFetchAllDetails event,
    Emitter<UserDetailsState> emit,
  ) async {
    log(
      '[UserDetailsBloc] _onUserDetailsEventFetchAllDetails called for userId: ${event.userId}',
    );
    emit(
      state.copyWith(
        user: event.initialUser,
        userState:
            event.initialUser != null
                ? UserDetailsStatus.success
                : UserDetailsStatus.loading,
        postsStatus: UserDetailsStatus.loading,
        todosStatus: UserDetailsStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final results = await Future.wait([
        // Fetch User if not passed initially
        if (event.initialUser == null)
          _userService.fetchUserDetails(
            event.userId,
          ), // Ensure this method exists in UserService

        _userService.fetchUserPosts(event.userId),
        _userService.fetchUserTodos(event.userId),
      ]);

      User? fetchedUser = event.initialUser;
      if (event.initialUser == null) {
        fetchedUser = results[0] as User;
      }

      int postsIndex = (event.initialUser == null) ? 1 : 0;
      int todosIndex = (event.initialUser == null) ? 2 : 1;

      final postListResponse = results[postsIndex] as PostListResponse;
      final todoListResponse = results[todosIndex] as TodoListResponse;

      emit(
        state.copyWith(
          user: fetchedUser,
          userState: UserDetailsStatus.success,
          posts: postListResponse.posts,
          postsStatus: UserDetailsStatus.success,
          todos: todoListResponse.todos,
          todosStatus: UserDetailsStatus.success,
        ),
      );
    } catch (e, stackTrace) {
      log(
        'Error fetching user details/posts/todos: $e',
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          userState:
              state.user == null ? UserDetailsStatus.failure : state.userState,
          postsStatus:
              UserDetailsStatus.failure, // Assume posts/todos might have failed
          todosStatus: UserDetailsStatus.failure,
          errorMessage: 'Failed to load details: ${e.toString()}',
        ),
      );
    }
  }
}
