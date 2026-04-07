import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/user_model.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthState.initial()) {
    on<_AppStarted>(_onAppStarted);
    on<_SignUpRequested>(_onSignUp);
    on<_SignInRequested>(_onSignIn);
    on<_SignOutRequested>(_onSignOut);
  }

  final AuthService _authService;

  Future<void> _onAppStarted(
    _AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      emit(const AuthState.unauthenticated());
      return;
    }
    try {
      final user = await _authService.getUserProfile(firebaseUser.uid);
      emit(AuthState.authenticated(user));
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onSignUp(
    _SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final UserModel user;
      if (event.role == UserRole.business) {
        user = await _authService.signUpBusiness(
          email: event.email,
          password: event.password,
          firstName: event.firstName,
          lastName: event.lastName,
          businessName: event.businessName!,
        );
      } else {
        user = await _authService.signUpPlayer(
          email: event.email,
          password: event.password,
          firstName: event.firstName,
          lastName: event.lastName,
        );
      }
      emit(AuthState.authenticated(user));
    } on Exception catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignIn(
    _SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } on Exception catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignOut(
    _SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(const AuthState.unauthenticated());
  }
}
