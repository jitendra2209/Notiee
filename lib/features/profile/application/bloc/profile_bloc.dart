import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/model/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadProfile);
    on<ProfileUpdateRequested>(_onUpdateProfile);
    on<ProfilePasswordUpdateRequested>(_onUpdatePassword);
    on<ProfilePictureUpdateRequested>(_onUpdateProfilePicture);
  }

  Future<void> _onLoadProfile(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _repository.getUserProfile(event.userId);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _repository.updateProfile(event.profile);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileUpdateSuccess('Profile updated successfully'));
        // Reload the profile
        add(ProfileLoadRequested(event.profile.id!));
      },
    );
  }

  Future<void> _onUpdatePassword(
    ProfilePasswordUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _repository.updatePassword(
      userId: event.userId,
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileUpdateSuccess('Password updated successfully')),
    );
  }

  Future<void> _onUpdateProfilePicture(
    ProfilePictureUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _repository.uploadProfilePicture(
      userId: '', // This should be provided
      imagePath: event.imagePath,
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (imageUrl) => emit(
          const ProfileUpdateSuccess('Profile picture updated successfully')),
    );
  }
}
