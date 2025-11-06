import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await SecureStorage.getToken();
    Map<String, String> headers = Map.from(ApiConfig.headers);

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJsonT);
    } on SocketException {
      return _errorResponse('Không có kết nối internet');
    } on TimeoutException {
      return _errorResponse('Kết nối quá thời gian');
    } on FormatException {
      return _errorResponse('Dữ liệu không hợp lệ');
    } catch (e) {
      return _errorResponse('Lỗi kết nối: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: await _getHeaders(),
          body: jsonEncode(data),
        )
        .timeout(ApiConfig.receiveTimeout);

    return _handleResponse<T>(response, fromJsonT);
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJsonT);
    } on SocketException {
      return _errorResponse('Không có kết nối internet');
    } on TimeoutException {
      return _errorResponse('Kết nối quá thời gian');
    } on FormatException {
      return _errorResponse('Dữ liệu không hợp lệ');
    } catch (e) {
      return _errorResponse('Lỗi kết nối: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJsonT);
    } on SocketException {
      return _errorResponse('Không có kết nối internet');
    } on TimeoutException {
      return _errorResponse('Kết nối quá thời gian');
    } on FormatException {
      return _errorResponse('Dữ liệu không hợp lệ');
    } catch (e) {
      return _errorResponse('Lỗi kết nối: $e');
    }
  }

  // file: api_service.dart

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    // In ra để debug
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // BƯỚC 1: Kiểm tra mã trạng thái TRƯỚC TIÊN
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // BƯỚC 2: Chỉ giải mã JSON KHI thành công
      try {
        // Xử lý trường hợp body rỗng (ví dụ: 204 No Content)
        if (response.body.isEmpty) {
          return ApiResponse<T>(
            success: true,
            message: 'Thành công',
            data: null, // Hoặc một giá trị T mặc định
            statusCode: response.statusCode,
          );
        }

        // Tiến hành giải mã
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Logic cũ của bạn
        return ApiResponse<T>(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Thành công',
          data:
              fromJsonT != null && responseData['data'] != null
                  ? fromJsonT(
                    responseData,
                  ) // Repository sẽ trích xuất 'data' từ đây
                  : responseData as T?,
          statusCode: response.statusCode,
        );
      } on FormatException catch (e) {
        print('FormatException khi decode body: $e');
        return _errorResponse(
          'Lỗi xử lý dữ liệu: $e. Body nhận được: ${response.body}',
          response.statusCode,
        );
      } catch (e) {
        // Các lỗi khác
        return _errorResponse('Lỗi không xác định: $e', response.statusCode);
      }
    }
    // BƯỚC 3: Xử lý các mã lỗi (Không giải mã JSON)
    else if (response.statusCode == 401) {
      return _errorResponse(
        'Tài khoản hoặc mật khẩu không hợp lệ!',
        response.statusCode,
      );
    } else if (response.statusCode == 403) {
      return _errorResponse('Không có quyền truy cập', response.statusCode);
    } else if (response.statusCode == 404) {
      return _errorResponse('Không tìm thấy dữ liệu', response.statusCode);
    } else if (response.statusCode == 422) {
      // Thử decode body lỗi, vì 422 của Laravel thường là JSON
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return _errorResponse(
          errorData['message'] ?? 'Dữ liệu không hợp lệ',
          response.statusCode,
        );
      } catch (e) {
        return _errorResponse('Dữ liệu không hợp lệ', response.statusCode);
      }
    } else if (response.statusCode == 429) {
      // Lỗi Rate Limiting
      return _errorResponse(
        'Bạn thao tác quá nhanh, vui lòng thử lại sau!',
        response.statusCode,
      );
    } else if (response.statusCode >= 500) {
      // Lỗi 500 (Server Error, Timeout)
      // response.body lúc này có thể là HTML hoặc chuỗi bị cắt
      return _errorResponse(
        'Lỗi máy chủ: ${response.body}',
        response.statusCode,
      );
    } else {
      // Các lỗi 4xx khác
      return _errorResponse(
        'Có lỗi xảy ra: ${response.body}',
        response.statusCode,
      );
    }
  }

  ApiResponse<T> _errorResponse<T>(String message, [int statusCode = 0]) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
