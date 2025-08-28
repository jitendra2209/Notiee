import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/contact_model.dart';
import '../domain/models/group_model.dart';
import '../domain/repositories/group_repository.dart';
import 'contacts_service.dart';

class GroupRepositoryImpl implements GroupRepository {
  final FirebaseFirestore _db;

  GroupRepositoryImpl(FirebaseAuth auth, this._db);

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groups');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Stream<List<GroupModel>> getUserGroups(String userPhone) {
    return _groups
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return GroupModel.fromJson(data);
          })
          .where((group) =>
              // Filter groups where user is a member
              group.members.any((member) => member.phoneNumber == userPhone))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<GroupModel>>> getGroupsByMonth(
      String userPhone, int month, int year) async {
    try {
      final snapshot = await _groups
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .orderBy('createdAt', descending: true)
          .get();

      final groups = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return GroupModel.fromJson(data);
          })
          .where((group) =>
              // Filter groups where user is a member
              group.members.any((member) => member.phoneNumber == userPhone))
          .toList();

      return right(groups);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupModel>> createGroup({
    required String name,
    required String description,
    required String creatorId,
    required String creatorPhone,
    required List<GroupMember> members,
    required int month,
    required int year,
  }) async {
    try {
      final now = DateTime.now();
      final group = GroupModel(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        creatorId: creatorId,
        creatorPhone: creatorPhone,
        members: members,
        createdAt: now,
        updatedAt: now,
        month: month,
        year: year,
      );

      final docRef = await _groups.add(group.toJson());
      final createdGroup = group.copyWith(id: docRef.id);

      return right(createdGroup);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupModel>> updateGroup(GroupModel group) async {
    try {
      final updatedGroup = group.copyWith(updatedAt: DateTime.now());
      await _groups.doc(group.id).update(updatedGroup.toJson());
      return right(updatedGroup);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGroup(
      String groupId, String userId) async {
    try {
      // First check if user is the creator
      final doc = await _groups.doc(groupId).get();
      if (!doc.exists) {
        return left(const DatabaseFailure('Group not found'));
      }

      final group = GroupModel.fromJson({...doc.data()!, 'id': doc.id});
      if (group.creatorId != userId) {
        return left(
            const DatabaseFailure('Only group creator can delete the group'));
      }

      await _groups.doc(groupId).delete();
      return right(unit);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addMemberToGroup(
      String groupId, GroupMember member) async {
    try {
      await _groups.doc(groupId).update({
        'members': FieldValue.arrayUnion([member.toJson()]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return right(unit);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeMemberFromGroup(
      String groupId, String memberPhone) async {
    try {
      final doc = await _groups.doc(groupId).get();
      if (!doc.exists) {
        return left(const DatabaseFailure('Group not found'));
      }

      final group = GroupModel.fromJson({...doc.data()!, 'id': doc.id});
      final updatedMembers = group.members
          .where((member) => member.phoneNumber != memberPhone)
          .toList();

      await _groups.doc(groupId).update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return right(unit);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContactModel>>> getPhoneContacts() async {
    try {
      // Try to get real device contacts
      final contacts = await ContactsService.getDeviceContacts();

      // If no contacts or permission denied, return mock contacts
      if (contacts.isEmpty) {
        final mockContacts = ContactsService.getMockContacts();
        return right(mockContacts);
      }

      return right(contacts);
    } catch (e) {
      // Fallback to mock contacts if there's any error
      try {
        final mockContacts = ContactsService.getMockContacts();
        return right(mockContacts);
      } catch (mockError) {
        return left(
            DatabaseFailure('Failed to load contacts: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, List<ContactModel>>> getRegisteredContacts(
      List<String> phoneNumbers) async {
    try {
      final registeredContacts = <ContactModel>[];

      // Check which phone numbers are registered users
      for (final phone in phoneNumbers) {
        final userQuery =
            await _users.where('phoneNumber', isEqualTo: phone).limit(1).get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          registeredContacts.add(ContactModel(
            displayName: userData['displayName'] ?? 'Unknown User',
            phoneNumber: phone,
            isRegistered: true,
            userId: userData['uid'],
          ));
        }
      }

      return right(registeredContacts);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
