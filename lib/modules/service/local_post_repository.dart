import 'dart:convert';
import 'package:flutter_user_bloc_assessment/modules/create_post/model/local_post_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles storing and retrieving posts locally using SharedPreferences.
class LocalPostRepository {
  static const String _postKey = 'local_posts';

  /// Returns the list of locally saved posts.
  Future<List<LocalPostModel>> getLocalPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? postJsonString = prefs.getString(_postKey);
      if (postJsonString != null) {
        final List<dynamic> decodedJson =
            json.decode(postJsonString) as List<dynamic>;
        return decodedJson
            .map(
              (jsonPost) =>
                  LocalPostModel.fromJson(jsonPost as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Saves a list of posts to local storage.
  Future<void> saveLocalPosts(List<LocalPostModel> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodedPosts =
          posts.map((post) => post.toJson()).toList();
      final String postJsonString = json.encode(encodedPosts);
      await prefs.setString(_postKey, postJsonString);
    } catch (_) {
      // Optionally handle/log errors
    }
  }

  /// Adds a new post and returns the saved instance with a new ID.
  Future<LocalPostModel> addPost(LocalPostModel newPost) async {
    final currentPosts = await getLocalPosts();
    final int maxId = currentPosts.fold<int>(
      0,
      (max, post) => post.id > max ? post.id : max,
    );
    final postWithId = newPost.copyWith(id: maxId + 1);
    currentPosts.add(postWithId);
    await saveLocalPosts(currentPosts);
    return postWithId;
  }

  /// Deletes a post by ID.
  Future<void> deletePost(int postId) async {
    try {
      final currentPosts = await getLocalPosts();
      currentPosts.removeWhere((post) => post.id == postId);
      await saveLocalPosts(currentPosts);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
