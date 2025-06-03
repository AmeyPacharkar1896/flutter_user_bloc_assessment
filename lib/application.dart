import 'package:flutter/material.dart';
import 'package:flutter_user_bloc_assessment/global_provider.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/main_screen_wrapper.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'User Management App',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const MainScreenWrapper(),
      ),
    );
  }
}
