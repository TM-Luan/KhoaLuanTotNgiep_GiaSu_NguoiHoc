import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    try {
      // THAY ĐỔI: Sử dụng dynamic thay vì Map<String, dynamic>
      final response = await _apiService.post<dynamic>(
        ApiConfig.login,
        data: {'Email': email, 'MatKhau': password},
      );

      // FIX: response.data bây giờ là Map<String, dynamic> chứa toàn bộ response
      if (response.success &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final token = responseData['token'];
        final userData = responseData['data'];

        if (token != null && token is String && token.isNotEmpty) {
          final loginResponse = LoginResponse.fromJson({
            'token': token,
            'data': userData ?? {},
          });

          return ApiResponse<LoginResponse>(
            success: true,
            message: response.message,
            data: loginResponse,
            statusCode: response.statusCode,
          );
        }
      }
      return ApiResponse<LoginResponse>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Lỗi đăng nhập: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<String>> register({
    required String hoTen,
    required String email,
    required String matKhau,
    required String soDienThoai,
    required int vaiTro,
    required String confirmPass,
  }) async {
    final response = await _apiService.post<dynamic>(
      ApiConfig.register,
      data: {
        'HoTen': hoTen,
        'Email': email,
        'MatKhau': matKhau,
        'MatKhau_confirmation': confirmPass,
        'SoDienThoai': soDienThoai,
        'VaiTro': vaiTro,
      },
    );

    return ApiResponse<String>(
      success: response.success,
      message: response.message,
      data: response.data?.toString(),
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<String>> logout(String token) async {
    final response = await _apiService.post<dynamic>(ApiConfig.logout);

    return ApiResponse<String>(
      success: response.success,
      message: response.message,
      data: response.data?.toString(),
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    return await _apiService.get<UserModel>(
      ApiConfig.profile,
      fromJsonT: (json) => UserModel.fromJson(json),
    );
  }
}
