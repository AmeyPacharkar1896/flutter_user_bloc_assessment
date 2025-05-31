import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/core/api/user_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/bloc/user_list_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_screen.dart';

class UserListView extends StatelessWidget {
  UserListView({super.key});
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserListBloc(userService: _userService),
      child: UserListScreen(),
    );
  }
}
