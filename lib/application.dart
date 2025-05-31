import 'package:flutter/material.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_view.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: UserListView(),
    );
  }
}
