import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/bloc/create_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/view/create_post_screen.dart';
import 'package:flutter_user_bloc_assessment/core/service/local_post_repository.dart';

class CreatePostView extends StatelessWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreatePostBloc>(
      create:
          (context) => CreatePostBloc(
            localPostRepository: RepositoryProvider.of<LocalPostRepository>(
              context,
            ),
          ),
      child: const CreatePostScreen(),
    );
  }
}
