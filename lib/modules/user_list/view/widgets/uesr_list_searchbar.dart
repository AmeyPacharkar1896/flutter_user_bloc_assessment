import 'package:flutter/material.dart';

class UserListSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const UserListSearchBar({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search User by name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                  Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            ),
          );
        },
      ),
    );
  }
}
