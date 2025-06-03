import 'package:flutter/material.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart';

class UserInfoHeaderWidget extends StatelessWidget {
  final User user;

  const UserInfoHeaderWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 45.0,
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    user.image.isNotEmpty ? NetworkImage(user.image) : null,
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
                        color:
                            Theme.of(context).colorScheme.onPrimary
                              ..withAlpha((0.85 * 255).toInt()),
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
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    final color =
        Theme.of(context).colorScheme.onPrimary
          ..withAlpha((0.85 * 255).toInt());
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
