part of 'bill_bloc.dart';

sealed class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

final class BillInitial extends BillState {}

final class BillLoading extends BillState {}

final class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object> get props => [message];
}

final class GroupsLoaded extends BillState {
  final List<GroupModel> groups;
  final Map<int, List<GroupModel>> groupsByMonth;

  const GroupsLoaded({
    required this.groups,
    required this.groupsByMonth,
  });

  @override
  List<Object> get props => [groups, groupsByMonth];
}

final class GroupsLoadedByMonth extends BillState {
  final List<GroupModel> groups;
  final int month;
  final int year;

  const GroupsLoadedByMonth({
    required this.groups,
    required this.month,
    required this.year,
  });

  @override
  List<Object> get props => [groups, month, year];
}

final class GroupCreated extends BillState {
  final GroupModel group;

  const GroupCreated(this.group);

  @override
  List<Object> get props => [group];
}

final class GroupUpdated extends BillState {
  final GroupModel group;

  const GroupUpdated(this.group);

  @override
  List<Object> get props => [group];
}

final class GroupDeleted extends BillState {
  final String groupId;

  const GroupDeleted(this.groupId);

  @override
  List<Object> get props => [groupId];
}

final class ContactsLoaded extends BillState {
  final List<ContactModel> contacts;
  final List<ContactModel> registeredContacts;

  const ContactsLoaded({
    required this.contacts,
    required this.registeredContacts,
  });

  @override
  List<Object> get props => [contacts, registeredContacts];
}

final class MemberAdded extends BillState {
  final String groupId;
  final GroupMember member;

  const MemberAdded(this.groupId, this.member);

  @override
  List<Object> get props => [groupId, member];
}

final class MemberRemoved extends BillState {
  final String groupId;
  final String memberPhone;

  const MemberRemoved(this.groupId, this.memberPhone);

  @override
  List<Object> get props => [groupId, memberPhone];
}
