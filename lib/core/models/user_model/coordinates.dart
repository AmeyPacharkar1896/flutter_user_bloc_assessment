import 'package:equatable/equatable.dart';

class Coordinates extends Equatable {
  final double lat;
  final double lng;

  const Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }

  Coordinates copyWith({double? lat, double? lng}) {
    return Coordinates(lat: lat ?? this.lat, lng: lng ?? this.lng);
  }

  @override
  List<Object?> get props => [lat, lng];
}
