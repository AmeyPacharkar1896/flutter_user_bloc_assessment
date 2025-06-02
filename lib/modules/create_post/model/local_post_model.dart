import 'package:equatable/equatable.dart';

class LocalPostModel extends Equatable {
  final int id;
  final String title;
  final String body;
  // final DataTime createdAt;

  const LocalPostModel({
    required this.id,
    required this.title,
    required this.body,
    // required this.createdAt,
  });

  LocalPostModel copyWith({
    int? id,
    String? title,
    String? body,
    // DataTime? createdAt,
  }) {
    return LocalPostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      // createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      // 'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocalPostModel.fromJson(Map<String, dynamic> json) {
    return LocalPostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      // createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, title, body /*createdAt*/];
}
