import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/bloc/create_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/view/create_post_screen.dart';

class CreatePostView extends StatelessWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePostBloc(),
      child: CreatePostScreen(),
    );
  }
}
