import 'package:equatable/equatable.dart';

class Reactions extends Equatable {
  final int likes;
  final int dislikes;

  const Reactions({required this.likes, required this.dislikes});

  factory Reactions.fromJson(Map<String, dynamic> json) {
    return Reactions(
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'likes': likes, 'dislikes': dislikes};
  }

  Reactions copyWith({int? likes, int? dislikes}) {
    return Reactions(
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
    );
  }

  @override
  List<Object?> get props => [likes, dislikes];
}
