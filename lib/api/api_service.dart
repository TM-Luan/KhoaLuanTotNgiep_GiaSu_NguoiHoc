import 'dart:convert';
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

    Map<String, String> headers = ApiConfig.headers;

    if (token != null) {
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
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi kết nối: $e',
        statusCode: 0,
      );
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

      // ĐẶC BIỆT: Cho endpoint login, luôn trả về Map<String, dynamic>
      if (endpoint == ApiConfig.login && fromJsonT == null) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ApiResponse<T>(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? '',
          data: responseData as T, // Trả về toàn bộ responseData
          error: responseData['error'],
          statusCode: response.statusCode,
        );
      }

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi kết nối: $e',
        statusCode: 0,
      );
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
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi kết nối: $e',
        statusCode: 0,
      );
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
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi kết nối: $e',
        statusCode: 0,
      );
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      print('🔍 API SERVICE - Raw response body: ${response.body}');
      print('🔍 API SERVICE - Parsed response data: $responseData');

      // QUAN TRỌNG: Truyền toàn bộ responseData cho fromJsonT
      // Vì token và data đều nằm ở root level
      return ApiResponse<T>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? '',
        data: fromJsonT != null ? fromJsonT(responseData) : null,
        error: responseData['error'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Parse error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi parse dữ liệu: $e',
        statusCode: response.statusCode,
      );
    }
  }
}
