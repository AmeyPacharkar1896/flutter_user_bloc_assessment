import 'package:flutter/material.dart';
import 'package:flutter_user_bloc_assessment/core/models/user_model/user_model.dart';

class UserInfoHeaderWidget extends StatelessWidget {
  final User user;

  const UserInfoHeaderWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryColor =
        Theme.of(
          context,
        ).colorScheme.onPrimary; // For text on primary background

    return Container(
      // Added a background color for the header area if image is transparent or fails
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.all(16.0).copyWith(
        top:
            kToolbarHeight +
            MediaQuery.of(context).padding.top +
            16, // Account for status bar & AppBar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment
                .end, // Align content to the bottom of flexible space
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.image),
                onBackgroundImageError: (exception, stackTrace) {
                  // Optionally log error or show placeholder indication
                },
                child:
                    user.image.isEmpty
                        ? Icon(Icons.person, size: 40, color: onPrimaryColor)
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
                        color: onPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: textTheme.titleMedium?.copyWith(
                        color: onPrimaryColor.withOpacity(0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Increased spacing
          Wrap(
            // Use Wrap for better layout of details if they overflow
            spacing: 16.0, // Horizontal space between items
            runSpacing: 8.0, // Vertical space between lines
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
              // Add more user details as needed
              // _buildDetailItem(context, Icons.location_city_outlined, 'City: ${user.address.city}'),
            ],
          ),
          const SizedBox(height: 10), // Some padding at the bottom
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min, // Important for Wrap
      children: [
        Icon(icon, size: 16, color: onPrimaryColor.withOpacity(0.85)),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: onPrimaryColor.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}
