import 'package:equatable/equatable.dart';
import 'address.dart'; // Reusing Address model

class Company extends Equatable {
  final String? department;
  final String name;
  final String? title;
  final Address address; // Reusing Address for company's address

  const Company({
    this.department,
    required this.name,
    this.title,
    required this.address,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      department: json['department'] as String?,
      name: json['name'] as String? ?? '',
      title: json['title'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'name': name,
      'title': title,
      'address': address.toJson(),
    };
  }

  Company copyWith({
    String? department,
    String? name,
    String? title,
    Address? address,
  }) {
    return Company(
      department: department ?? this.department,
      name: name ?? this.name,
      title: title ?? this.title,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [department, name, title, address];
}
