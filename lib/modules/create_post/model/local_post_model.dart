class LocalPostModel {
  int id;
  String title;
  String body;

  LocalPostModel({required this.id, required this.title, required this.body});

  LocalPostModel copyWith({int? id, String? title, String? body}) {
    return LocalPostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }
}
