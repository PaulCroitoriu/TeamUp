part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.appStarted() = _AppStarted;
  const factory AuthEvent.signUpRequested({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? businessName,
  }) = _SignUpRequested;
  const factory AuthEvent.signInRequested({required String email, required String password}) = _SignInRequested;
  const factory AuthEvent.signOutRequested() = _SignOutRequested;
}
