import 'dart:convert'; // For json.decode
import 'dart:developer';

import 'package:flutter_user_bloc_assessment/core/env_service.dart';
import 'package:flutter_user_bloc_assessment/core/models/user_model/user_list_response.dart';
import 'package:http/http.dart' as http; // Use 'as http' to avoid name clashes

class UserService {
  late final String _baseUrl;
  final http.Client client;

  // Constructor
  UserService({http.Client? httpClient})
    : client = httpClient ?? http.Client() {
    _baseUrl = EnvService.baseUrl;
  }

  String get _usersBaseEndpoint => "$_baseUrl/users";
  String _userPostsEndpoint(int userId) => "$_baseUrl/posts/user/$userId";
  String _userTodosEndpoint(int userId) => "$_baseUrl/todos/user/$userId";

  // --- User List ---
  Future<UserListResponse> fetchUserList({
    int limit = 10,
    int skip = 0,
    String? query,
  }) async {
    try {
      Map<String, String> queryParams = {
        'limit': limit.toString(),
        'skip': skip.toString(),
      };
      if (query != null && query.isNotEmpty) {
        // The API uses /users/search?q=
        // So the base endpoint needs to change for search
        final String searchEndpoint = "$_usersBaseEndpoint/search";
        queryParams['q'] = query;

        final Uri searchUrl = Uri.parse(
          searchEndpoint,
        ).replace(queryParameters: queryParams);
        log('Fetching users with search: $searchUrl');
        final response = await client.get(searchUrl);

        if (response.statusCode == 200) {
          log('Search Response body: ${response.body}');
          final Map<String, dynamic> jsonBody = json.decode(response.body);
          return UserListResponse.fromJson(jsonBody);
        } else {
          log(
            'Error fetching users (search): ${response.statusCode} - ${response.body}',
          );
          throw Exception(
            'Failed to load users (search): ${response.statusCode}',
          );
        }
      } else {
        // Normal fetch without search
        final Uri usersUrl = Uri.parse(
          _usersBaseEndpoint,
        ).replace(queryParameters: queryParams);
        log('Fetching users: $usersUrl');
        final response = await client.get(usersUrl);

        if (response.statusCode == 200) {
          log('Response body: ${response.body}');
          final Map<String, dynamic> jsonBody = json.decode(response.body);
          return UserListResponse.fromJson(jsonBody);
        } else {
          log(
            'Error fetching users: ${response.statusCode} - ${response.body}',
          );
          throw Exception('Failed to load users: ${response.statusCode}');
        }
      }
    } catch (e) {
      log('Exception in fetchUserList: $e');
      // Rethrow or handle as a specific application error
      throw Exception(
        'Failed to load users. Check network connection or API status. Error: $e',
      );
    }
  }
}
