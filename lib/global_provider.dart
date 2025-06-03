import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/bloc/create_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/service/local_post_repository.dart';
import 'package:flutter_user_bloc_assessment/modules/service/user_service.dart';

class GlobalProvider extends StatelessWidget {
  const GlobalProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserService>(create: (_) => UserService()),
        RepositoryProvider<LocalPostRepository>(
          create: (_) => LocalPostRepository(),
        ),
      ],
      child: BlocProvider<CreatePostBloc>(
        create:
            (context) => CreatePostBloc(
              localPostRepository: context.read<LocalPostRepository>(),
            ),
        child: child,
      ),
    );
  }
}
