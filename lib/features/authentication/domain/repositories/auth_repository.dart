import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<AppUser?> authUserStream();
  Future<Either<Failure, Unit>> signUpWithPassword({
    required String phone,
    required String password,
    String? displayName,
  });
  Future<Either<Failure, Unit>> loginWithPassword({
    required String phone,
    required String password,
  });
  Future<void> signOut();
}
