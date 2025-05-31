import 'package:equatable/equatable.dart';
import 'coordinates.dart'; // Assuming coordinates.dart is in the same directory or adjust path

class Address extends Equatable {
  final String address;
  final String city;
  final String? state; // Marked as nullable if it might be missing
  final String? stateCode; // Marked as nullable
  final String postalCode;
  final Coordinates coordinates;
  final String? country; // Marked as nullable

  const Address({
    required this.address,
    required this.city,
    this.state,
    this.stateCode,
    required this.postalCode,
    required this.coordinates,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String?,
      stateCode: json['stateCode'] as String?,
      postalCode: json['postalCode'] as String? ?? '',
      coordinates: Coordinates.fromJson(
        json['coordinates'] as Map<String, dynamic>? ?? {},
      ),
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'stateCode': stateCode,
      'postalCode': postalCode,
      'coordinates': coordinates.toJson(),
      'country': country,
    };
  }

  Address copyWith({
    String? address,
    String? city,
    String? state,
    String? stateCode,
    String? postalCode,
    Coordinates? coordinates,
    String? country,
  }) {
    return Address(
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      postalCode: postalCode ?? this.postalCode,
      coordinates: coordinates ?? this.coordinates,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [
    address,
    city,
    state,
    stateCode,
    postalCode,
    coordinates,
    country,
  ];
}
