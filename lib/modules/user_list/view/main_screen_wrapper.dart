import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/bloc/create_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/view/create_post_view.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/bloc/local_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/view/local_post_screen.dart';
import 'package:flutter_user_bloc_assessment/core/service/local_post_repository.dart';
import 'package:flutter_user_bloc_assessment/core/service/user_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/bloc/user_list_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_screen.dart';

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = [const UserListScreen(), const LocalPostScreen()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getAppBarTitle() {
    return switch (_selectedIndex) {
      0 => 'Users',
      1 => 'My Local Posts',
      _ => 'User App',
    };
  }

  Future<void> _navigateToCreatePost(BuildContext contextForBlocAccess) async {
    final createPostBloc = contextForBlocAccess.read<CreatePostBloc>();
    final localPostBloc = contextForBlocAccess.read<LocalPostBloc>();

    final createdPost = await Navigator.of(context).push<LocalPostModel>(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: createPostBloc,
              child: const CreatePostView(),
            ),
      ),
    );

    if (createdPost != null && mounted) {
      localPostBloc.add(LocalPostEventLoad());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserListBloc>(
          create:
              (ctx) =>
                  UserListBloc(userService: ctx.read<UserService>())
                    ..add(const UserListFetchUsers()),
        ),
        BlocProvider<LocalPostBloc>(
          create:
              (ctx) => LocalPostBloc(
                localPostRepository: ctx.read<LocalPostRepository>(),
              )..add(LocalPostEventLoad()),
        ),
        // CreatePostBloc is globally provided from Application.dart
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          actions: [
            if (_selectedIndex <= 1)
              Builder(
                builder: (contextWithBlocAccess) {
                  return IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Create Post',
                    onPressed:
                        () => _navigateToCreatePost(contextWithBlocAccess),
                  );
                },
              ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).primaryColorDark,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'My Posts',
            ),
          ],
        ),
      ),
    );
  }
}
