import 'package:equatable/equatable.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserProfile user;
  final String? token;
  const AuthAuthenticated(this.user, {this.token});
  @override
  List<Object?> get props => [user];
}

class AuthRegistered extends AuthState {
  final String message;
  const AuthRegistered(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class PasswordChanged extends AuthState {
  final String message;
  const PasswordChanged(this.message);
  @override
  List<Object?> get props => [message];
}

class PasswordReset extends AuthState {
  final String message;
  const PasswordReset(this.message);
  @override
  List<Object?> get props => [message];
}
