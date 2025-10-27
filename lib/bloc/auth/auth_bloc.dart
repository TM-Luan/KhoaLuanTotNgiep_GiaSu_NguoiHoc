import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc(this.authRepository) : super(const AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<FetchProfileRequested>(_onFetchProfile);
    on<LogoutRequested>(_onLogout);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final ApiResponse<LoginResponse> res = await authRepository.login(
      e.email,
      e.password,
    );
    if (res.success && res.data != null) {
      // Lưu token để ApiService tự đính kèm Authorization cho các request sau
      await SecureStorage.setToken(res.data!.token);
      emit(AuthAuthenticated(res.data!.user));
    } else {
      emit(AuthError(res.message));
    }
  }

  Future<void> _onRegister(RegisterRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final r = await authRepository.register(
      hoTen: e.hoTen,
      email: e.email,
      matKhau: e.matKhau,
      confirmPass: e.confirmPass,
      soDienThoai: e.soDienThoai,
      vaiTro: e.vaiTro,
    );
    if (r.success) {
      emit(AuthRegistered(r.message));
    } else {
      emit(AuthError(r.message));
    }
  }

  Future<void> _onFetchProfile(
    FetchProfileRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final r = await authRepository.getProfile();
    if (r.success && r.data != null) {
      emit(AuthAuthenticated(r.data!));
    } else {
      emit(AuthError(r.message));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    // Gọi API, nhưng quan trọng là xoá token local để ngăn request tiếp theo
    try {
      await authRepository.logout('');
    } catch (_) {}
    await SecureStorage.clearToken();
    emit(const AuthLoggedOut());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final r = await authRepository.updateProfile(e.user);
    if (r.success && r.data != null) {
      emit(AuthAuthenticated(r.data!));
    } else {
      emit(AuthError(r.message));
    }
  }
}
