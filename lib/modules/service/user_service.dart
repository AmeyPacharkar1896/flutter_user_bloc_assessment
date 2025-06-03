// file: lib/modules/service/user_service.dart (or core/service/user_service.dart)
import 'dart:async'; // For TimeoutException
import 'dart:convert';
import 'dart:developer';
import 'dart:io'; // For SocketException

import 'package:flutter_user_bloc_assessment/core/env_service.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/post_models/post_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_details/model/todo_models/todo_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_list_response.dart';
import 'package:flutter_user_bloc_assessment/modules/user_list/model/user_model.dart';
import 'package:http/http.dart' as http;

// Custom Exception for better error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode; // Optional: to hold HTTP status code
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UserService {
  late final String _baseUrl;
  final http.Client client;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  UserService({http.Client? httpClient})
    : client = httpClient ?? http.Client() {
    _baseUrl = EnvService.baseUrl;
  }

  String get _usersBaseEndpoint => "$_baseUrl/users";
  String _userDetailsEndpoint(int userId) => "$_usersBaseEndpoint/$userId";
  String _userPostsEndpoint(int userId) => "$_baseUrl/posts/user/$userId";
  String _userTodosEndpoint(int userId) => "$_baseUrl/todos/user/$userId";

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (response.statusCode == 200) {
      try {
        log(
          'API Response body: ${response.body.substring(0, (response.body.length > 500 ? 500 : response.body.length))}...',
        ); // Log snippet
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        return fromJson(jsonBody);
      } catch (e) {
        log('JSON Parsing Error: $e \nBody: ${response.body}');
        throw ApiException(
          'Failed to parse server response. Please try again.',
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      log('Client Error: ${response.statusCode} - ${response.body}');
      // Try to parse error message from body if API provides one
      // String errorMessage = "An error occurred (Code: ${response.statusCode}).";
      // try {
      //   final errorJson = json.decode(response.body);
      //   if (errorJson['message'] != null) errorMessage = errorJson['message'];
      // } catch (_) {}
      throw ApiException(
        'Request error (Code: ${response.statusCode}). Please try again.',
        statusCode: response.statusCode,
      );
    } else {
      log('Server Error: ${response.statusCode} - ${response.body}');
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
      Map<String, String> queryParams = {
        'limit': limit.toString(),
        'skip': skip.toString(),
      };
      String endpointToParse;
      if (query != null && query.isNotEmpty) {
        endpointToParse = "$_usersBaseEndpoint/search";
        queryParams['q'] = query;
      } else {
        endpointToParse = _usersBaseEndpoint;
      }
      final Uri requestUrl = Uri.parse(
        endpointToParse,
      ).replace(queryParameters: queryParams);
      log('Fetching: $requestUrl');
      final response = await client.get(requestUrl).timeout(_timeoutDuration);
      return _handleResponse(response, UserListResponse.fromJson);
    } on SocketException catch (e) {
      log('Network Error (SocketException) in fetchUserList: $e');
      throw ApiException(
        'Network error. Please check your internet connection and try again.',
      );
    } on TimeoutException catch (e) {
      log('Timeout Error in fetchUserList: $e');
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      // Re-throw custom API exceptions
      rethrow;
    } catch (e) {
      log('Generic Exception in fetchUserList: $e');
      throw ApiException(
        'An unexpected error occurred while fetching users. Please try again.',
      );
    }
  }

  Future<User> fetchUserDetails(int userId) async {
    try {
      final Uri userDetailsUrl = Uri.parse(_userDetailsEndpoint(userId));
      log('Fetching user details for userId $userId: $userDetailsUrl');
      final response = await client
          .get(userDetailsUrl)
          .timeout(_timeoutDuration);
      return _handleResponse(response, User.fromJson);
    } on SocketException catch (e) {
      log('Network Error (SocketException) in fetchUserDetails: $e');
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      log('Timeout Error in fetchUserDetails: $e');
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (e) {
      log('Generic Exception in fetchUserDetails for userId $userId: $e');
      throw ApiException(
        'An unexpected error occurred while fetching user details.',
      );
    }
  }

  Future<PostListResponse> fetchUserPosts(int userId) async {
    try {
      final url = Uri.parse(_userPostsEndpoint(userId));
      log('Fetching posts for user $userId: $url');
      final response = await client.get(url).timeout(_timeoutDuration);
      return _handleResponse(response, PostListResponse.fromJson);
    } on SocketException catch (e) {
      log('Network Error (SocketException) in fetchUserPosts: $e');
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      log('Timeout Error in fetchUserPosts: $e');
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (e) {
      log('Generic Exception in fetchUserPosts for userId $userId: $e');
      throw ApiException('An unexpected error occurred while fetching posts.');
    }
  }

  Future<TodoListResponse> fetchUserTodos(int userId) async {
    try {
      final url = Uri.parse(_userTodosEndpoint(userId));
      log('Fetching todos for user $userId: $url');
      final response = await client.get(url).timeout(_timeoutDuration);
      return _handleResponse(response, TodoListResponse.fromJson);
    } on SocketException catch (e) {
      log('Network Error (SocketException) in fetchUserTodos: $e');
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      log('Timeout Error in fetchUserTodos: $e');
      throw ApiException('The request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (e) {
      log('Generic Exception in fetchUserTodos for userId $userId: $e');
      throw ApiException('An unexpected error occurred while fetching todos.');
    }
  }
}
