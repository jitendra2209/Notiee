import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String? uid;
  final String? phoneNumber;
  final String? displayName;
  final String? passwordHash;
  final String? salt;

  const AppUser({
    this.uid,
    this.phoneNumber,
    this.displayName,
    this.passwordHash,
    this.salt,
  });

  AppUser copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? passwordHash,
    String? salt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'passwordHash': passwordHash,
      'salt': salt,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      passwordHash: json['passwordHash'] as String?,
      salt: json['salt'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [uid, phoneNumber, displayName, passwordHash, salt];
}
