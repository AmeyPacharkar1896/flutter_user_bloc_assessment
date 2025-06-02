// file: lib/modules/main_app/main_screen_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/bloc/create_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';
import 'package:flutter_user_bloc_assessment/modules/create_post/view/create_post_view.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/bloc/local_post_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/local_post/view/local_post_screen.dart';
import 'package:flutter_user_bloc_assessment/modules/service/local_post_repository.dart';
import 'package:flutter_user_bloc_assessment/modules/service/user_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/bloc/user_list_bloc.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/view/user_list_screen.dart'; // This is your UI content

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Define the pages/screens for the PageView
  final List<Widget> _pages = [
    const UserListScreen(), // Your existing UserListScreen widget (UI part)
    const LocalPostScreen(),
  ];

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
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // or animateToPage for smooth transition
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Users';
      case 1:
        return 'My Local Posts';
      default:
        return 'User App';
    }
  }

  // In UserListView (your main screen wrapper, e.g., _UserListViewState)

  void _navigateToCreatePost(BuildContext iconButtonContext) async {
    // Get the BLoC instances using the context that can see them BEFORE the await
    final CreatePostBloc createPostBlocInstance =
        iconButtonContext.read<CreatePostBloc>();
    final LocalPostBloc localPostsBlocInstance =
        iconButtonContext.read<LocalPostBloc>();

    final postCreated = await Navigator.of(this.context).push<LocalPostModel>(
      // Use this.context for Navigator
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: createPostBlocInstance, // Pass the instance
              child: CreatePostView(),
            ),
      ),
    );

    if (postCreated is LocalPostModel && mounted) {
      // Use the BLoC instance obtained before the await
      localPostsBlocInstance.add(LocalPostEventLoad());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide BLoCs needed by the pages within this UserListView
    // UserListBloc is for the UserListScreen page
    // LocalPostsBloc is for the LocalPostsScreen page
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserListBloc>(
          create:
              (ctx) => UserListBloc(userService: ctx.read<UserService>())..add(
                const UserListFetchUsers(),
              ), // Initial fetch for users list
        ),
        BlocProvider<LocalPostBloc>(
          create:
              (ctx) => LocalPostBloc(
                localPostRepository: ctx.read<LocalPostRepository>(),
              )..add(
                LocalPostEventLoad(),
              ), // Load local posts when LocalPostsBloc is created
        ),
        // CreatePostBloc is already provided globally by Application.dart
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          actions: [
            if (_selectedIndex == 0 || _selectedIndex == 1)
              Builder(
                // Use Builder to get a context directly under MultiBlocProvider
                builder: (buttonBuilderContext) {
                  return IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Create Post',
                    onPressed:
                        () => _navigateToCreatePost(
                          buttonBuilderContext,
                        ), // Pass this specific context
                  );
                },
              ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _pages, // Use the _pages list
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
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
          currentIndex: _selectedIndex,
          selectedItemColor:
              Theme.of(context).primaryColorDark, // Example color
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
