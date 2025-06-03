import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_user_bloc_assessment/core/env_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/post_models/post_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/todo_models/todo_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart';
import 'package:http/http.dart' as http;

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Service responsible for fetching user-related data from the API
class UserService {
  late final String _baseUrl;
  final http.Client client;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  UserService({http.Client? httpClient})
    : client = httpClient ?? http.Client() {
    _baseUrl = EnvService.baseUrl;
  }

  String get _usersEndpoint => '$_baseUrl/users';
  String _userDetailsEndpoint(int userId) => '$_usersEndpoint/$userId';
  String _userPostsEndpoint(int userId) => '$_baseUrl/posts/user/$userId';
  String _userTodosEndpoint(int userId) => '$_baseUrl/todos/user/$userId';

  /// General handler for API responses
  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        return fromJson(jsonBody);
      } catch (_) {
        throw ApiException(
          'Failed to parse server response. Please try again.',
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException(
        'Request error (Code: ${response.statusCode}). Please try again.',
        statusCode: response.statusCode,
      );
    } else {
      throw ApiException(
        'Server error (Code: ${response.statusCode}). Please try again later.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<UserListResponse> fetchUserList({
    int limit = 20,
    int skip = 0,
    String? query,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'limit': limit.toString(),
        'skip': skip.toString(),
      };

      final String endpoint =
          (query != null && query.isNotEmpty)
              ? '$_usersEndpoint/search'
              : _usersEndpoint;

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final Uri requestUrl = Uri.parse(
        endpoint,
      ).replace(queryParameters: queryParams);

      final response = await client.get(requestUrl).timeout(_timeoutDuration);
      return _handleResponse(response, UserListResponse.fromJson);
    } on SocketException {
      throw ApiException(
        'Network error. Please check your internet connection and try again.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('An unexpected error occurred while fetching users.');
    }
  }

  Future<User> fetchUserDetails(int userId) async {
    try {
      final Uri url = Uri.parse(_userDetailsEndpoint(userId));
      final response = await client.get(url).timeout(_timeoutDuration);
      return _handleResponse(response, User.fromJson);
    } on SocketException {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'An unexpected error occurred while fetching user details.',
      );
    }
  }

  Future<PostListResponse> fetchUserPosts(int userId) async {
    try {
      final Uri url = Uri.parse(_userPostsEndpoint(userId));
      final response = await client.get(url).timeout(_timeoutDuration);
      return _handleResponse(response, PostListResponse.fromJson);
    } on SocketException {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('An unexpected error occurred while fetching posts.');
    }
  }

  Future<TodoListResponse> fetchUserTodos(int userId) async {
    try {
      final Uri url = Uri.parse(_userTodosEndpoint(userId));
      final response = await client.get(url).timeout(_timeoutDuration);
      return _handleResponse(response, TodoListResponse.fromJson);
    } on SocketException {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('An unexpected error occurred while fetching todos.');
    }
  }
}
