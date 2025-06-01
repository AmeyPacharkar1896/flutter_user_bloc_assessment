import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/core/service/user_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/bloc/user_list_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_screen.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              UserListBloc(userService: context.read<UserService>())
                ..add(const UserListFetchUsers()),
      child: UserListScreen(),
    );
  }
}
