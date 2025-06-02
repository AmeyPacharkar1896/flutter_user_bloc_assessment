// file: lib/modules/user_details/views/widget/user_info_header_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart';

class UserInfoHeaderWidget extends StatelessWidget {
  final User user;

  const UserInfoHeaderWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // For a header section, you might want to use card-like styling or just padding
    // The background color will come from its parent or be transparent.

    return Container(
      padding: const EdgeInsets.all(16.0),
      // color: Theme.of(context).colorScheme.surfaceVariant, // Optional: subtle background
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // Match your app bar color
        // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.image),
                onBackgroundImageError: (exception, stackTrace) {},
                child:
                    user.image.isEmpty
                        ? Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.fullName,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withOpacity(0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              _buildDetailItem(
                context,
                Icons.person_outline,
                'Username: ${user.username}',
              ),
              _buildDetailItem(
                context,
                Icons.phone_outlined,
                'Phone: ${user.phone}',
              ),
              _buildDetailItem(
                context,
                Icons.cake_outlined,
                'Age: ${user.age}',
              ),
              _buildDetailItem(
                context,
                user.gender == 'male'
                    ? Icons.male_outlined
                    : Icons.female_outlined,
                'Gender: ${user.gender}',
              ),
            ],
          ),
          // No need for SizedBox(height: 10) at the end if it's the last item in its container.
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}
