import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

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

  @override
  Future<Either<Failure, String>> sendOtp({required String phone}) async {
    try {
      final completer = Completer<String>();
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(AuthFailure(e.message ?? 'OTP failed'));
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
      );
      final verificationId = await completer.future;
      return right(verificationId);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) return left(AuthFailure('Sign-in failed'));
      final doc = await _users.doc(user.uid).get();
      if (!doc.exists) {
        final appUser = AppUser(uid: user.uid, phoneNumber: user.phoneNumber);
        await _users
            .doc(user.uid)
            .set(appUser.copyWith(uid: user.uid).toJson());
        return right(appUser);
      }
      return right(AppUser.fromJson(doc.data()!));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signUpWithPassword({
    required String phone,
    required String password,
    String? displayName,
  }) async {
    try {
      final current = _auth.currentUser;
      if (current == null) return left(AuthFailure('Not verified by OTP'));
      final uid = current.uid;
      final docRef = _users.doc(uid);
      final snap = await docRef.get();
      final salt = generateSalt();
      final hash = hashPassword(password, salt);
      final user = AppUser(
        uid: uid,
        phoneNumber: phone,
        displayName: displayName,
        passwordHash: hash,
        salt: salt,
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
      final current = _auth.currentUser;
      if (current == null) return left(AuthFailure('Not verified by OTP'));
      final doc = await _users.doc(current.uid).get();
      if (!doc.exists) return left(NotFoundFailure('User not found'));
      final data = doc.data()!;
      if (data['phoneNumber'] != phone) {
        return left(AuthFailure('Phone mismatch'));
      }
      final salt = data['salt'] as String?;
      final storedHash = data['passwordHash'] as String?;
      if (salt == null || storedHash == null) {
        return left(AuthFailure('Password not set'));
      }
      final inputHash = hashPassword(password, salt);
      if (inputHash != storedHash) {
        return left(AuthFailure('Invalid password'));
      }
      return right(unit);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPasswordWithOtp({
    required String phone,
    required String newPassword,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final verifyRes = await verifyOtpAndSignIn(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await verifyRes.fold(
        (l) => left(l),
        (user) async {
          if (user.phoneNumber != phone) {
            return left(AuthFailure('Phone mismatch'));
          }
          final salt = generateSalt();
          final hash = hashPassword(newPassword, salt);
          await _users.doc(user.uid!).update({
            'passwordHash': hash,
            'salt': salt,
          });
          return right(unit);
        },
      );
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
