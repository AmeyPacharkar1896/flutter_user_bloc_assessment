import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart';
import 'package:flutter_user_bloc_assessment/modules/service/user_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/user_details_screen.dart';

/// Provides UserDetailsBloc and initializes it with the userId and optional initial user data.
class UserDetailsView extends StatelessWidget {
  final int userId;
  final User? initialUser;

  const UserDetailsView({super.key, required this.userId, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserDetailsBloc>(
      create:
          (blocContext) =>
              UserDetailsBloc(userService: blocContext.read<UserService>())
                ..add(
                  UserDetailsEventFetchAllDetails(
                    userId: userId,
                    initialUser: initialUser,
                  ),
                ),
      child: const UserDetailsScreen(),
    );
  }
}
