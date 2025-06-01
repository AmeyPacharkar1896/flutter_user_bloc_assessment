import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/core/models/user_model/user_model.dart';
import 'package:flutter_user_bloc_assessment/core/service/user_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/bloc/user_details_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/views/user_details_screen.dart';

class UserDetailsView extends StatelessWidget {
  const UserDetailsView({super.key, required this.userId, this.initialUser});
  final int userId;
  final User? initialUser;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (blocContext) =>
              UserDetailsBloc(userService: blocContext.read<UserService>())
                ..add(
                  UserDetailsEventFetchAllDetails(
                    userId: userId,
                    initialUser: initialUser,
                  ),
                ),
      child: UserDetailsScreen(),
    );
  }
}
