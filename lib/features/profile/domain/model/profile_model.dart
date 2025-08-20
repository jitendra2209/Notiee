import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String? id;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final String? profilePictureUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    this.id,
    this.name,
    this.phoneNumber,
    this.email,
    this.profilePictureUrl,
    this.createdAt,
    this.updatedAt,
  });

  ProfileModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return ProfileModel(
      id: json['uid'] as String?,
      name: json['displayName'] as String? ?? json['name'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        profilePictureUrl,
        createdAt,
        updatedAt,
      ];
}
