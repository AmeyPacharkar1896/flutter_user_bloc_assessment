import 'dart:convert';
import 'dart:developer';

import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPostRepository {
  static const String _postKey = 'local_posts';

  Future<List<LocalPostModel>> getLocalPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? postJsonString = prefs.getString(_postKey);
      if (postJsonString != null) {
        final List<dynamic> decodedJson =
            json.decode(postJsonString) as List<dynamic>;
        final List<LocalPostModel> posts =
            decodedJson
                .map(
                  (jsonPost) =>
                      LocalPostModel.fromJson(jsonPost as Map<String, dynamic>),
                )
                .toList();
        log(
          '[LocalPostRepo] Loaded ${posts.length} posts from SharedPreferences.',
        );
        return posts;
      }
      log('[LocalPostRepo] No posts found in SharedPreferences.');
      return [];
    } catch (e) {
      log('[LocalPostRepo] Error loading posts: $e');
      return [];
    }
  }

  Future<void> saveLocalPosts(List<LocalPostModel> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodedPosts =
          posts.map((post) => post.toJson()).toList();
      final String postJsonString = json.encode(encodedPosts);
      await prefs.setString(_postKey, postJsonString);
      log('[LocalPostRepo] Saved ${posts.length} posts to SharedPreferences.');
    } catch (e) {
      log('[LocalPostRepo] Error saving posts: $e');
    }
  }

  Future<LocalPostModel> addPost(LocalPostModel newPost) async {
    final List<LocalPostModel> currentPosts = await getLocalPosts();
    int maxId = 0;
    for (var post in currentPosts) {
      if (post.id > maxId) maxId = post.id;
    }
    final postWithId = newPost.copyWith(id: maxId + 1);

    currentPosts.add(postWithId);
    await saveLocalPosts(currentPosts);
    log('[LocalPostRepo] Added new post: ${postWithId.title}');
    return postWithId;
  }

  Future<void> deletePost(int postId) async {
    try {
      final List<LocalPostModel> currentPosts = await getLocalPosts();
      // Remove the post with the matching ID
      currentPosts.removeWhere((post) => post.id == postId);
      await saveLocalPosts(currentPosts);
      log(
        '[LocalPostRepo] Deleted post with ID: $postId. Remaining posts: ${currentPosts.length}',
      );
    } catch (e) {
      log('[LocalPostRepo] Error deleting post with ID $postId: $e');
      // Optionally rethrow or handle as needed
      throw Exception('Failed to delete post: $e');
    }
  }
}
