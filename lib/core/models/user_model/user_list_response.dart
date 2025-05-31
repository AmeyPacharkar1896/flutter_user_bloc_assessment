import 'package:equatable/equatable.dart';
import 'user_model.dart'; // Assuming user_model.dart is in the same directory

class UserListResponse extends Equatable {
  final List<User> users;
  final int total;
  final int skip;
  final int limit;

  const UserListResponse({
    required this.users,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    var userList =
        (json['users'] as List<dynamic>?)
            ?.map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
            .toList() ??
        <User>[];

    return UserListResponse(
      users: userList,
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }

  UserListResponse copyWith({
    List<User>? users,
    int? total,
    int? skip,
    int? limit,
  }) {
    return UserListResponse(
      users: users ?? this.users,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [users, total, skip, limit];
}
