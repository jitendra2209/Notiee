import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../domain/model/profile_model.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  ProfileRepositoryImpl(this._auth, this._db);

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Future<Either<Failure, ProfileModel>> getUserProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) {
        // Create a new profile document if it doesn't exist
        final currentUser = _auth.currentUser;
        final newProfile = ProfileModel(
          id: userId,
          name: currentUser?.displayName ?? '',
          phoneNumber: currentUser?.phoneNumber ?? '',
          email: currentUser?.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _users.doc(userId).set(newProfile.toJson());
        return right(newProfile);
      }

      final data = doc.data()!;
      final profile = ProfileModel.fromJson(data, doc.id);
      return right(profile);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileModel profile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return left(const AuthFailure('User not authenticated'));
      }

      await _users.doc(userId).update(profile.toJson());
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return left(const AuthFailure('User not authenticated'));
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return left(const AuthFailure('Current password is incorrect'));
      } else if (e.code == 'weak-password') {
        return left(const AuthFailure('New password is too weak'));
      }
      return left(AuthFailure(e.message ?? 'Password update failed'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture({
    required String userId,
    required String imagePath,
  }) async {
    try {
      // For now, return a placeholder URL
      // In a real implementation, you would upload to Firebase Storage
      return right('https://via.placeholder.com/150');
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
