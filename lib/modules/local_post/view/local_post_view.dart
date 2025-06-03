import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/bloc/local_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/view/local_post_screen.dart';
import 'package:flutter_user_bloc_assessment/core/service/local_post_repository.dart';

class LocalPostView extends StatelessWidget {
  const LocalPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => LocalPostBloc(
            localPostRepository: context.read<LocalPostRepository>(),
          ),
      child: const LocalPostScreen(),
    );
  }
}
