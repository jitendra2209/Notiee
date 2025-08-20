import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignupWithPasswordRequested extends AuthEvent {
  final String phone;
  final String password;
  final String? displayName;
  final String? email;
  const AuthSignupWithPasswordRequested(this.phone, this.password,
      {this.displayName, this.email});
  @override
  List<Object?> get props => [phone, password, displayName, email];
}

class AuthLoginWithPasswordRequested extends AuthEvent {
  final String phone;
  final String password;
  const AuthLoginWithPasswordRequested(this.phone, this.password);
  @override
  List<Object?> get props => [phone, password];
}

class AuthSignOutRequested extends AuthEvent {
  final Function() onSuccess;
  final Function() onFailure;
  const AuthSignOutRequested(
      {required this.onSuccess, required this.onFailure});
  @override
  List<Object?> get props => [onSuccess, onFailure];
}
