
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/auth_service.dart';

import '../models/user_model.dart';
class AuthRepository {
  final AuthService _service = AuthService();

  Future<ApiResponse<User>> login(String email, String password) =>
      _service.login(email, password);

  Future<ApiResponse<String>> register({
    required String hoTen,
    required String email,
    required String matKhau,
    required String soDienThoai,
    required int vaiTro,
  }) =>
      _service.register(
        hoTen: hoTen,
        email: email,
        matKhau: matKhau,
        soDienThoai: soDienThoai,
        vaiTro: vaiTro,
      );

  Future<ApiResponse<String>> logout(String token) =>
      _service.logout(token);
}
