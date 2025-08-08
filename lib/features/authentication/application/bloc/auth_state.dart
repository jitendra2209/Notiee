import 'package:equatable/equatable.dart';
import '../../../authentication/domain/models/user_model.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isOtpSent;
  final String? verificationId;
  final AppUser? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isOtpSent = false,
    this.verificationId,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isOtpSent,
    String? verificationId,
    AppUser? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      verificationId: verificationId ?? this.verificationId,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isOtpSent, verificationId, user, error];
}
