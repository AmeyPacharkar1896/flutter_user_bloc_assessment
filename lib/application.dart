// application.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/service/local_post_repository.dart';
import 'package:flutter_user_bloc_assessment/modules/service/user_service.dart'; // Ensure correct path
import 'package:flutter_user_bloc_assessment/modules/create_post/bloc/create_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_view.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserService>(create: (context) => UserService()),
        RepositoryProvider<LocalPostRepository>(
          create: (context) => LocalPostRepository(),
        ),
      ],
      child: BlocProvider<CreatePostBloc>(
        // Provide CreatePostBloc globally for FAB access
        create:
            (context) => CreatePostBloc(
              localPostRepository: context.read<LocalPostRepository>(),
            ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'User Management App', // Give your app a title
          theme: ThemeData(
            // Example theme
            primarySwatch: Colors.indigo,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: const UserListView(), // <<<< Use MainScreenWrapper here
        ),
      ),
    );
  }
}
