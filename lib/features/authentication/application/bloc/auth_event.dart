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

class AuthSignOutRequested extends AuthEvent {}
