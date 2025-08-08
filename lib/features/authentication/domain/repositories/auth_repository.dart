import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<AppUser?> authUserStream();
  Future<Either<Failure, String>> sendOtp({required String phone});
  Future<Either<Failure, AppUser>> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  });
  Future<Either<Failure, Unit>> signUpWithPassword({
    required String phone,
    required String password,
    String? displayName,
  });
  Future<Either<Failure, Unit>> loginWithPassword({
    required String phone,
    required String password,
  });
  Future<Either<Failure, Unit>> resetPasswordWithOtp({
    required String phone,
    required String newPassword,
    required String verificationId,
    required String smsCode,
  });
  Future<void> signOut();
}
