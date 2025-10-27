import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.login,
        data: {'Email': email, 'MatKhau': password},
        fromJsonT: (json) => json, // Trả về raw data
      );

      if (response.success && response.data != null) {
        final responseData = response.data!;

        // Validate dữ liệu trước khi parse
        if (!responseData.containsKey('token') ||
            !responseData.containsKey('data')) {
          return ApiResponse<LoginResponse>(
            success: false,
            message: 'Dữ liệu phản hồi không đúng định dạng',
            statusCode: response.statusCode,
          );
        }

        final loginResponse = LoginResponse.fromJson(responseData);

        return ApiResponse<LoginResponse>(
          success: true,
          message: response.message,
          data: loginResponse,
          statusCode: response.statusCode,
        );
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
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.register,
        data: {
          'HoTen': hoTen,
          'Email': email,
          'MatKhau': matKhau,
          'MatKhau_confirmation': confirmPass,
          'SoDienThoai': soDienThoai,
          'VaiTro': vaiTro,
        },
        fromJsonT: (json) => json,
      );

      return ApiResponse<String>(
        success: response.success,
        message: response.message,
        data: response.data?.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Lỗi đăng ký: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<String>> logout(String token) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.logout,
        fromJsonT: (json) => json,
      );

      return ApiResponse<String>(
        success: response.success,
        message: response.message,
        data: response.data?.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Lỗi đăng xuất: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<UserProfile>> getProfile() async {
    try {
      return await _apiService.get<UserProfile>(
        ApiConfig.profile,
        fromJsonT: (json) => UserProfile.fromJson(json['data'] ?? {}),
      );
    } catch (e) {
      return ApiResponse<UserProfile>(
        success: false,
        message: 'Lỗi lấy thông tin: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<UserProfile>> updateProfile(UserProfile user) async {
    try {
      final response = await _apiService.put<UserProfile>(
        ApiConfig.updateProfile,
        data: user.toJson(),
        fromJsonT: (json) => UserProfile.fromJson(json['data'] ?? json),
      );

      return ApiResponse<UserProfile>(
        success: response.success,
        message: response.message,
        data: response.data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<UserProfile>(
        success: false,
        message: 'Lỗi cập nhật thông tin: $e',
        statusCode: 0,
      );
    }
  }
}
