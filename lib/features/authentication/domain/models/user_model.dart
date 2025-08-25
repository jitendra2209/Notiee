import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String? uid;
  final String? phoneNumber;
  final String? displayName;
  final String? password;
  final String? email;

  const AppUser({
    this.uid,
    this.phoneNumber,
    this.displayName,
    this.password,
    this.email,
  });

  AppUser copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? password,
    String? email,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      password: password ?? this.password,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'password': password,
      'email': email,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
    );
  }

  @override
  List<Object?> get props => [uid, phoneNumber, displayName, password, email];
}
