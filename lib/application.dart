// application.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:flutter_user_bloc_assessment/core/service/user_service.dart'; // Import UserService
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_view.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap your MaterialApp with RepositoryProvider for UserService
    return RepositoryProvider<UserService>(
      create:
          (context) => UserService(), // Create a single instance of UserService
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UserListView(),
      ),
    );
  }
}
