import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure(String m) : super(m);
}

class AuthFailure extends Failure {
  const AuthFailure(String m) : super(m);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String m) : super(m);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String m) : super(m);
}
