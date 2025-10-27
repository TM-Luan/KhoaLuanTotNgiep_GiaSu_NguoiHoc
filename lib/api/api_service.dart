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
    try {
      final response = await http
          .post(
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

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // Kiểm tra status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Thành công',
          data: fromJsonT != null && responseData['data'] != null
              ? fromJsonT(responseData)
              : responseData as T?,
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<T>(
          success: false,
          message: 'Phiên đăng nhập hết hạn',
          error: responseData['error'],
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 403) {
        return ApiResponse<T>(
          success: false,
          message: 'Không có quyền truy cập',
          error: responseData['error'],
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse<T>(
          success: false,
          message: 'Không tìm thấy dữ liệu',
          error: responseData['error'],
          statusCode: response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        return ApiResponse<T>(
          success: false,
          message: 'Lỗi máy chủ',
          error: responseData['error'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Có lỗi xảy ra',
          error: responseData['error'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi xử lý dữ liệu: $e',
        statusCode: response.statusCode,
      );
    }
  }

  ApiResponse<T> _errorResponse<T>(String message) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: 0,
    );
  }
}