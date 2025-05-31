import 'package:equatable/equatable.dart';
import 'reactions_model.dart'; // Assuming reactions_model.dart is in the same directory

class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final Reactions reactions;
  final int views;
  final int userId;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.reactions,
    required this.views,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag as String)
              .toList() ??
          <String>[],
      reactions: Reactions.fromJson(
        json['reactions'] as Map<String, dynamic>? ?? {},
      ),
      views: json['views'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'tags': tags,
      'reactions': reactions.toJson(),
      'views': views,
      'userId': userId,
    };
  }

  Post copyWith({
    int? id,
    String? title,
    String? body,
    List<String>? tags,
    Reactions? reactions,
    int? views,
    int? userId,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      reactions: reactions ?? this.reactions,
      views: views ?? this.views,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, title, body, tags, reactions, views, userId];
}
