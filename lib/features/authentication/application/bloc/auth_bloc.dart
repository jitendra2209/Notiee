import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthSendOtpRequested>(_onSendOtp);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthSignupWithPasswordRequested>(_onSignup);
    on<AuthLoginWithPasswordRequested>(_onLogin);
    on<AuthForgotPasswordSendOtpRequested>(_onForgotOtp);
    on<AuthResetPasswordWithOtpRequested>(_onResetPwd);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    await emit.forEach(_repo.authUserStream(), onData: (user) {
      return state.copyWith(user: user, error: null);
    });
  }

  Future<void> _onSendOtp(
      AuthSendOtpRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, isOtpSent: false));
    final res = await _repo.sendOtp(phone: e.phone);
    res.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (verificationId) => emit(state.copyWith(
        isLoading: false,
        isOtpSent: true,
        verificationId: verificationId,
      )),
    );
  }

  Future<void> _onVerifyOtp(
      AuthVerifyOtpRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final res = await _repo.verifyOtpAndSignIn(
      verificationId: e.verificationId,
      smsCode: e.smsCode,
    );
    res.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (user) => emit(state.copyWith(isLoading: false, user: user, error: null)),
    );
  }

  Future<void> _onSignup(
      AuthSignupWithPasswordRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final res = await _repo.signUpWithPassword(
      phone: e.phone,
      password: e.password,
      displayName: e.displayName,
    );
    res.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (_) => emit(state.copyWith(isLoading: false, error: null)),
    );
  }

  Future<void> _onLogin(
      AuthLoginWithPasswordRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final res =
        await _repo.loginWithPassword(phone: e.phone, password: e.password);
    res.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (_) => emit(state.copyWith(isLoading: false, error: null)),
    );
  }

  Future<void> _onForgotOtp(
      AuthForgotPasswordSendOtpRequested e, Emitter<AuthState> emit) async {
    add(AuthSendOtpRequested(e.phone));
  }

  Future<void> _onResetPwd(
      AuthResetPasswordWithOtpRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final res = await _repo.resetPasswordWithOtp(
      phone: e.phone,
      newPassword: e.newPassword,
      verificationId: e.verificationId,
      smsCode: e.smsCode,
    );
    res.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (_) => emit(state.copyWith(isLoading: false, error: null)),
    );
  }

  Future<void> _onSignOut(
      AuthSignOutRequested e, Emitter<AuthState> emit) async {
    await _repo.signOut();
    emit(const AuthState());
  }
}
