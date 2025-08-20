import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String? uid;
  final String? phoneNumber;
  final String? displayName;
  final String? passwordHash;
  final String? salt;
  final String? email;

  const AppUser({
    this.uid,
    this.phoneNumber,
    this.displayName,
    this.passwordHash,
    this.salt,
    this.email,
  });

  AppUser copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? passwordHash,
    String? salt,
    String? email,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'passwordHash': passwordHash,
      'salt': salt,
      'email': email,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      passwordHash: json['passwordHash'] as String?,
      salt: json['salt'] as String?,
      email: json['email'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [uid, phoneNumber, displayName, passwordHash, salt, email];
}
