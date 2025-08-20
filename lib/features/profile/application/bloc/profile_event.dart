part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final ProfileModel profile;
  const ProfileUpdateRequested(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfilePasswordUpdateRequested extends ProfileEvent {
  final String userId;
  final String currentPassword;
  final String newPassword;
  const ProfilePasswordUpdateRequested({
    required this.userId,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [userId, currentPassword, newPassword];
}

class ProfilePictureUpdateRequested extends ProfileEvent {
  final String imagePath;
  const ProfilePictureUpdateRequested(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
