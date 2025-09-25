import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/user_model.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  AuthRepositoryImpl(this._auth, this._db);

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Stream<AppUser?> authUserStream() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _users.doc(user.uid).get();
      if (!doc.exists) {
        return AppUser(uid: user.uid, phoneNumber: user.phoneNumber);
      }
      final data = doc.data()!;
      return AppUser.fromJson(data);
    });
  }

  // OTP-based methods removed

  @override
  Future<Either<Failure, Unit>> signUpWithPassword({
    required String phone,
    required String password,
    String? displayName,
    required String email,
  }) async {
    try {
      // final email = _derivedEmailFromPhone(phone);
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      final docRef = _users.doc(uid);
      final snap = await docRef.get();
      final user = AppUser(
        uid: uid,
        phoneNumber: phone,
        displayName: displayName,
        email: email,
        password: password, // Store plain text password
      );
      if (snap.exists) {
        await docRef.update(user.toJson());
      } else {
        await docRef.set(user.toJson());
      }
      return right(unit);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    try {
      // Find user by phone number to get their actual email
      final querySnapshot =
          await _users.where('phoneNumber', isEqualTo: phone).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        return left(AuthFailure('No user found with this phone number'));
      }

      final userData = querySnapshot.docs.first.data();
      final userEmail = userData['email'] as String?;

      if (userEmail == null || userEmail.isEmpty) {
        return left(AuthFailure('Email not found for this phone number'));
      }

      // Use the actual email for authentication
      await _auth.signInWithEmailAndPassword(
          email: userEmail, password: password);
      return right(unit);
    } catch (e) {
      return left(AuthFailure('Invalid phone or password'));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
