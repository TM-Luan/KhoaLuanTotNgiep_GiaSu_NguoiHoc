// file: auth_repository.dart (ĐÃ SỬA)

import 'dart:io';

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

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
        unpackData: false, // <-- SỬA QUAN TRỌNG: KHÔNG MỞ GÓI DATA
      );

      if (response.success && response.data != null) {
        final responseData = response.data!;

        // Bây giờ 'responseData' là toàn bộ JSON,
        // và kiểm tra này sẽ thành công
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
        // Giả định register KHÔNG cần token ở root.
        // Nếu nó cũng trả về token ở root, hãy thêm: unpackData: false
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
        // Giả định logout KHÔNG cần token ở root.
        // Nếu nó cũng trả về token ở root, hãy thêm: unpackData: false
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
      // getProfile dùng logic MỞ GÓI (unpackData: true là mặc định)
      // nên code này (đã sửa ở lần trước) là ĐÚNG
      return await _apiService.get<UserProfile>(
        ApiConfig.profile,
        fromJsonT: (data) => UserProfile.fromJson(data ?? {}),
        // unpackData: true (mặc định)
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
      // 1. Tạo FormData
      final Map<String, dynamic> textData = user.toJson();
      textData['_method'] = 'PUT';
      final formData = FormData.fromMap(textData);

      // 2. Hàm trợ giúp để thêm file vào FormData
      Future<void> addFileToFormData(File? file, String key) async {
        if (file != null) {
          String fileName = p.basename(file.path);
          String fileExtension = p.extension(file.path).toLowerCase();

          MediaType contentType;
          if (fileExtension == '.png') {
            contentType = MediaType('image', 'png');
          } else if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
            contentType = MediaType('image', 'jpeg');
          } else if (fileExtension == '.gif') {
            contentType = MediaType('image', 'gif');
          } else {
            contentType = MediaType('application', 'octet-stream');
          }

          formData.files.add(
            MapEntry(
              key,
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
                contentType: contentType,
              ),
            ),
          );
        }
      }

      // 3. Thêm các file
      await addFileToFormData(user.newAnhDaiDienFile, 'AnhDaiDien');
      await addFileToFormData(user.newAnhCCCDMatTruocFile, 'AnhCCCD_MatTruoc');
      await addFileToFormData(user.newAnhCCCDMatSauFile, 'AnhCCCD_MatSau');
      await addFileToFormData(user.newAnhBangCapFile, 'AnhBangCap');

      // 4. Gửi request
      // updateProfile dùng logic MỞ GÓI (unpackData: true là mặc định)
      final response = await _apiService.post<UserProfile>(
        ApiConfig.updateProfile,
        data: formData,
        fromJsonT: (data) => UserProfile.fromJson(data ?? {}),
        // unpackData: true (mặc định)
      );

      return ApiResponse<UserProfile>(
        success: response.success,
        message: response.message,
        data: response.data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      String errorMessage = 'Lỗi cập nhật thông tin: $e';
      if (e is DioException) {
        errorMessage = 'Lỗi Dio: ${e.message}';
        if (e.response != null) {
          errorMessage += '\nData: ${e.response?.data}';
        }
      }

      return ApiResponse<UserProfile>(
        success: false,
        message: errorMessage,
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.changePassword,
        data: {
          'MatKhauHienTai': currentPassword,
          'MatKhauMoi': newPassword,
          'MatKhauMoi_confirmation': confirmPassword,
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
        message: 'Lỗi đổi mật khẩu: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<String>> forgotPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.resetPassword,
        data: {
          'Email': email,
          'MatKhauMoi': newPassword,
          'MatKhauMoi_confirmation': confirmPassword,
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
        message: 'Lỗi đặt lại mật khẩu: $e',
        statusCode: 0,
      );
    }
  }
}