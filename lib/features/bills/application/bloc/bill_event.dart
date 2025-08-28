part of 'bill_bloc.dart';

sealed class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object> get props => [];
}

// Load groups for the current user
class LoadUserGroups extends BillEvent {
  final String userPhone;

  const LoadUserGroups(this.userPhone);

  @override
  List<Object> get props => [userPhone];
}

// Load groups for a specific month
class LoadGroupsByMonth extends BillEvent {
  final String userPhone;
  final int month;
  final int year;

  const LoadGroupsByMonth(this.userPhone, this.month, this.year);

  @override
  List<Object> get props => [userPhone, month, year];
}

// Create a new group
class CreateGroup extends BillEvent {
  final String name;
  final String description;
  final String creatorId;
  final String creatorPhone;
  final List<GroupMember> members;
  final int month;
  final int year;

  const CreateGroup({
    required this.name,
    required this.description,
    required this.creatorId,
    required this.creatorPhone,
    required this.members,
    required this.month,
    required this.year,
  });

  @override
  List<Object> get props =>
      [name, description, creatorId, creatorPhone, members, month, year];
}

// Update group
class UpdateGroup extends BillEvent {
  final GroupModel group;

  const UpdateGroup(this.group);

  @override
  List<Object> get props => [group];
}

// Delete group
class DeleteGroup extends BillEvent {
  final String groupId;
  final String userId;

  const DeleteGroup(this.groupId, this.userId);

  @override
  List<Object> get props => [groupId, userId];
}

// Load contacts
class LoadContacts extends BillEvent {
  const LoadContacts();
}

// Load registered contacts
class LoadRegisteredContacts extends BillEvent {
  final List<String> phoneNumbers;

  const LoadRegisteredContacts(this.phoneNumbers);

  @override
  List<Object> get props => [phoneNumbers];
}

// Add member to group
class AddMemberToGroup extends BillEvent {
  final String groupId;
  final GroupMember member;

  const AddMemberToGroup(this.groupId, this.member);

  @override
  List<Object> get props => [groupId, member];
}

// Remove member from group
class RemoveMemberFromGroup extends BillEvent {
  final String groupId;
  final String memberPhone;

  const RemoveMemberFromGroup(this.groupId, this.memberPhone);

  @override
  List<Object> get props => [groupId, memberPhone];
}
