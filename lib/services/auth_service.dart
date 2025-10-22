import 'package:dio/dio.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_model.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: Duration(milliseconds: ApiConfig.timeout),
    receiveTimeout: Duration(milliseconds: ApiConfig.timeout),
    headers: ApiConfig.getHeaders(),
  ));

  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _dio.post('login', data: {
        'Email': email,
        'MatKhau': password,
      });
      final user = User.fromJson(response.data);
      return ApiResponse.success(user);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Đăng nhập thất bại';
      return ApiResponse.error(msg);
    }
  }

  Future<ApiResponse<String>> register({
    required String hoTen,
    required String email,
    required String matKhau,
    required String soDienThoai,
    required int vaiTro,
  }) async {
    try {
      final response = await _dio.post('register', data: {
        'HoTen': hoTen,
        'Email': email,
        'MatKhau': matKhau,
        'SoDienThoai': soDienThoai,
        'VaiTro': vaiTro,
      });
      return ApiResponse.success(response.data['message']);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Đăng ký thất bại';
      return ApiResponse.error(msg);
    }
  }

  Future<ApiResponse<String>> logout(String token) async {
    try {
      final response = await _dio.post(
        'logout',
        options: Options(headers: ApiConfig.getHeaders(token: token)),
      );
      return ApiResponse.success(response.data['message'] ?? 'Đăng xuất thành công');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Đăng xuất thất bại';
      return ApiResponse.error(msg);
    }
  }
}
