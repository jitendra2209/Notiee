import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/group_model.dart';
import '../models/contact_model.dart';

abstract class GroupRepository {
  /// Stream of groups where the current user is a member
  Stream<List<GroupModel>> getUserGroups(String userPhone);

  /// Get groups for a specific month and year
  Future<Either<Failure, List<GroupModel>>> getGroupsByMonth(
      String userPhone, int month, int year);

  /// Create a new group
  Future<Either<Failure, GroupModel>> createGroup({
    required String name,
    required String description,
    required String creatorId,
    required String creatorPhone,
    required List<GroupMember> members,
    required int month,
    required int year,
  });

  /// Update group details
  Future<Either<Failure, GroupModel>> updateGroup(GroupModel group);

  /// Delete a group (only by creator)
  Future<Either<Failure, Unit>> deleteGroup(String groupId, String userId);

  /// Add member to group
  Future<Either<Failure, Unit>> addMemberToGroup(
      String groupId, GroupMember member);

  /// Remove member from group
  Future<Either<Failure, Unit>> removeMemberFromGroup(
      String groupId, String memberPhone);

  /// Get phone contacts (mock implementation for now)
  Future<Either<Failure, List<ContactModel>>> getPhoneContacts();

  /// Check which contacts are registered users
  Future<Either<Failure, List<ContactModel>>> getRegisteredContacts(
      List<String> phoneNumbers);
}
