import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  final String displayName;
  final String phoneNumber;
  final bool isRegistered;
  final String? userId;

  const ContactModel({
    required this.displayName,
    required this.phoneNumber,
    this.isRegistered = false,
    this.userId,
  });

  ContactModel copyWith({
    String? displayName,
    String? phoneNumber,
    bool? isRegistered,
    String? userId,
  }) {
    return ContactModel(
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isRegistered: isRegistered ?? this.isRegistered,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'isRegistered': isRegistered,
      'userId': userId,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      displayName: json['displayName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isRegistered: json['isRegistered'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }

  @override
  List<Object?> get props => [displayName, phoneNumber, isRegistered, userId];
}
