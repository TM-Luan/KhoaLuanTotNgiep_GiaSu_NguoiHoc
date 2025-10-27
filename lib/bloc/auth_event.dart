import 'package:equatable/equatable.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String hoTen;
  final String email;
  final String matKhau;
  final String confirmPass;
  final String soDienThoai;
  final int vaiTro; // 1: học viên, 2: gia sư ...
  const RegisterRequested({
    required this.hoTen,
    required this.email,
    required this.matKhau,
    required this.confirmPass,
    required this.soDienThoai,
    required this.vaiTro,
  });

  @override
  List<Object?> get props => [
    hoTen,
    email,
    matKhau,
    confirmPass,
    soDienThoai,
    vaiTro,
  ];
}

class FetchProfileRequested extends AuthEvent {
  const FetchProfileRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
class UpdateProfileRequested extends AuthEvent {
  final UserProfile user;
  const UpdateProfileRequested(this.user);
}
