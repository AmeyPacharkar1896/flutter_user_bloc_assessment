import 'package:equatable/equatable.dart';
import 'address.dart';
import 'company.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? maidenName;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String username;
  // final String password; // Generally not needed in the model for display
  final String birthDate;
  final String image; // URL for the avatar
  // final String bloodGroup;
  // final double height;
  // final double weight;
  // final String eyeColor;
  // final Map<String, String> hair; // Can be a separate Hair model if needed
  final Address address;
  final Company company;
  // final String? role; // If needed for UI differentiation

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.maidenName,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.username,
    required this.birthDate,
    required this.image,
    required this.address,
    required this.company,
    // this.role,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      maidenName: json['maidenName'] as String?,
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      username: json['username'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      image: json['image'] as String? ?? '',
      address: Address.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
      company: Company.fromJson(json['company'] as Map<String, dynamic>? ?? {}),
      // role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'maidenName': maidenName,
      'age': age,
      'gender': gender,
      'email': email,
      'phone': phone,
      'username': username,
      'birthDate': birthDate,
      'image': image,
      'address': address.toJson(),
      'company': company.toJson(),
      // 'role': role,
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? maidenName,
    int? age,
    String? gender,
    String? email,
    String? phone,
    String? username,
    String? birthDate,
    String? image,
    Address? address,
    Company? company,
    // String? role,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      maidenName: maidenName ?? this.maidenName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      birthDate: birthDate ?? this.birthDate,
      image: image ?? this.image,
      address: address ?? this.address,
      company: company ?? this.company,
      // role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    maidenName,
    age,
    gender,
    email,
    phone,
    username,
    birthDate,
    image,
    address,
    company,
    // role,
  ];
}
