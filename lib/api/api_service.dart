// file: api_service.dart (PHIÊN BẢN NÂNG CẤP DÙNG DIO)

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart'; // <--- Dùng Dio
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio; // <--- Khai báo Dio

  ApiService._internal() {
    // Cấu hình Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        receiveTimeout: ApiConfig.receiveTimeout,
        connectTimeout: const Duration(
          seconds: 10,
        ), // Bạn có thể thêm vào ApiConfig
        headers: ApiConfig.headers,
      ),
    );

    // Thêm Interceptor để tự động chèn Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token
          final String? token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Dio sẽ tự động xử lý 'Content-Type'
          // Nó sẽ là 'application/json' cho Map
          // và 'multipart/form-data' cho FormData
          return handler.next(options);
        },
        onError: (e, handler) {
          // Có thể xử lý lỗi 401 (hết hạn token) ở đây
          return handler.next(e);
        },
      ),
    );
  }

  // KHÔNG CẦN _getHeaders() nữa vì Interceptor đã xử lý

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final response = await _dio.get(endpoint);
      return _handleResponse<T>(response, fromJsonT);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data, // <--- CHỈ CẦN TRUYỀN DATA
        // Dio tự biết là JSON hay FormData
      );
      return _handleResponse<T>(response, fromJsonT);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data, // <--- TƯƠNG TỰ HÀM POST
      );
      return _handleResponse<T>(response, fromJsonT);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse<T>(response, fromJsonT);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  // Xử lý response thành công (cho mã 2xx)
  ApiResponse<T> _handleResponse<T>(
    Response response, // <--- Dùng Response của Dio
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    // Dio tự động giải mã JSON, nên response.data đã là Map
    final Map<String, dynamic> responseData = response.data;

    return ApiResponse<T>(
      success: responseData['success'] ?? true,
      message: responseData['message'] ?? 'Thành công',
      // Sửa lỗi logic: fromJsonT nên nhận vào responseData['data']
      data:
          fromJsonT != null
              ? fromJsonT(responseData) // Gửi cả responseData cho fromJsonT
              : responseData as T?,
      statusCode: response.statusCode ?? 0,
    );
  }

  // Xử lý lỗi (cho mã 4xx, 5xx, và lỗi mạng)
  ApiResponse<T> _errorResponse<T>(DioException? e, [String? customMessage]) {
    if (customMessage != null) {
      return ApiResponse<T>(
        success: false,
        message: customMessage,
        statusCode: 0,
      );
    }

    if (e == null) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi không xác định',
        statusCode: 0,
      );
    }

    // Xử lý các loại lỗi của Dio
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse<T>(
          success: false,
          message: 'Kết nối quá thời gian',
          statusCode: e.response?.statusCode ?? 0,
        );

      case DioExceptionType.badResponse:
        // Đây là nơi xử lý lỗi 4xx, 5xx
        if (e.response != null && e.response!.data is Map) {
          final errorData = e.response!.data as Map<String, dynamic>;
          return ApiResponse<T>(
            success: false,
            message: errorData['message'] ?? 'Có lỗi xảy ra',
            statusCode: e.response!.statusCode ?? 0,
          );
        }
        return ApiResponse<T>(
          success: false,
          message: 'Lỗi máy chủ: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode ?? 0,
        );

      case DioExceptionType.cancel:
        return ApiResponse<T>(
          success: false,
          message: 'Yêu cầu đã bị hủy',
          statusCode: 0,
        );

      case DioExceptionType.connectionError:
        return ApiResponse<T>(
          success: false,
          message: 'Không có kết nối internet',
          statusCode: 0,
        );

      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return ApiResponse<T>(
            success: false,
            message: 'Không có kết nối internet',
            statusCode: 0,
          );
        }
        return ApiResponse<T>(
          success: false,
          message: 'Lỗi: ${e.message}',
          statusCode: 0,
        );
    }
  }
}
