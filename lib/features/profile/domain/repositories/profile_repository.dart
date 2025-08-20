import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../model/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getUserProfile(String userId);
  Future<Either<Failure, Unit>> updateProfile(ProfileModel profile);
  Future<Either<Failure, Unit>> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, String>> uploadProfilePicture({
    required String userId,
    required String imagePath,
  });
}
