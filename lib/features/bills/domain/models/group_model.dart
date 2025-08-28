import 'package:equatable/equatable.dart';

class GroupModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String creatorPhone;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int month; // 1-12 for month tabs
  final int year;

  const GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.creatorPhone,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    required this.month,
    required this.year,
  });

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    String? creatorPhone,
    List<GroupMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? month,
    int? year,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorPhone: creatorPhone ?? this.creatorPhone,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'creatorPhone': creatorPhone,
      'members': members.map((member) => member.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'month': month,
      'year': year,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      creatorId: json['creatorId'] as String,
      creatorPhone: json['creatorPhone'] as String,
      members: (json['members'] as List<dynamic>?)
              ?.map((member) =>
                  GroupMember.fromJson(member as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      month: json['month'] as int,
      year: json['year'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        creatorId,
        creatorPhone,
        members,
        createdAt,
        updatedAt,
        month,
        year,
      ];
}

class GroupMember extends Equatable {
  final String phoneNumber;
  final String displayName;
  final String? userId; // Will be set if user is registered
  final DateTime joinedAt;

  const GroupMember({
    required this.phoneNumber,
    required this.displayName,
    this.userId,
    required this.joinedAt,
  });

  GroupMember copyWith({
    String? phoneNumber,
    String? displayName,
    String? userId,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'userId': userId,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String,
      userId: json['userId'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [phoneNumber, displayName, userId, joinedAt];
}
