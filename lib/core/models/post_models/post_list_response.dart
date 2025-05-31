import 'package:equatable/equatable.dart';
import 'post_model.dart'; // Assuming post_model.dart is in the same directory

class PostListResponse extends Equatable {
  final List<Post> posts;
  final int total;
  final int skip;
  final int limit;

  const PostListResponse({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    var postList =
        (json['posts'] as List<dynamic>?)
            ?.map((postJson) => Post.fromJson(postJson as Map<String, dynamic>))
            .toList() ??
        <Post>[];

    return PostListResponse(
      posts: postList,
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => post.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }

  PostListResponse copyWith({
    List<Post>? posts,
    int? total,
    int? skip,
    int? limit,
  }) {
    return PostListResponse(
      posts: posts ?? this.posts,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [posts, total, skip, limit];
}
