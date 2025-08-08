import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSendOtpRequested extends AuthEvent {
  final String phone;
  const AuthSendOtpRequested(this.phone);
  @override
  List<Object?> get props => [phone];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;
  const AuthVerifyOtpRequested(this.verificationId, this.smsCode);
  @override
  List<Object?> get props => [verificationId, smsCode];
}

class AuthSignupWithPasswordRequested extends AuthEvent {
  final String phone;
  final String password;
  final String? displayName;
  const AuthSignupWithPasswordRequested(this.phone, this.password,
      {this.displayName});
  @override
  List<Object?> get props => [phone, password, displayName];
}

class AuthLoginWithPasswordRequested extends AuthEvent {
  final String phone;
  final String password;
  const AuthLoginWithPasswordRequested(this.phone, this.password);
  @override
  List<Object?> get props => [phone, password];
}

class AuthForgotPasswordSendOtpRequested extends AuthEvent {
  final String phone;
  const AuthForgotPasswordSendOtpRequested(this.phone);
  @override
  List<Object?> get props => [phone];
}

class AuthResetPasswordWithOtpRequested extends AuthEvent {
  final String phone;
  final String newPassword;
  final String verificationId;
  final String smsCode;
  const AuthResetPasswordWithOtpRequested(
      this.phone, this.newPassword, this.verificationId, this.smsCode);
  @override
  List<Object?> get props => [phone, newPassword, verificationId, smsCode];
}

class AuthSignOutRequested extends AuthEvent {}
