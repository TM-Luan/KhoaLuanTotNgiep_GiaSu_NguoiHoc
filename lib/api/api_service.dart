// file: api_service.dart (PHIÊN BẢN SỬA LỖI DELETE)

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        receiveTimeout: ApiConfig.receiveTimeout,
        connectTimeout: const Duration(seconds: 10),
        headers: ApiConfig.headers,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(dynamic)? fromJsonT,
    bool unpackData = true,
  }) async {
    try {
      final response = await _dio.get(endpoint);
      return _handleResponse<T>(response, fromJsonT, unpackData);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    bool unpackData = true,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse<T>(response, fromJsonT, unpackData);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    bool unpackData = true,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse<T>(response, fromJsonT, unpackData);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJsonT,
    bool unpackData = true,
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse<T>(response, fromJsonT, unpackData);
    } on DioException catch (e) {
      return _errorResponse(e);
    } catch (e) {
      return _errorResponse(null, 'Lỗi không xác định: $e');
    }
  }

  // Xử lý response thành công (cho mã 2xx)
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJsonT,
    bool unpackData,
  ) {
    // === ⭐️ BẮT ĐẦU SỬA LỖI ⭐️ ===
    // Kiểm tra xem data có phải là Map không
    if (response.data is Map<String, dynamic>) {
      // Logic cũ (cho JSON Objects)
      final Map<String, dynamic> responseData = response.data;
      final dynamic dataToParse;
      if (unpackData) {
        dataToParse = responseData['data'];
      } else {
        dataToParse = responseData;
      }

      return ApiResponse<T>(
        success: responseData['success'] ?? true,
        message: responseData['message'] ?? 'Thành công',
        data:
            fromJsonT != null && dataToParse != null
                ? fromJsonT(dataToParse)
                : (dataToParse as T?),
        statusCode: response.statusCode ?? 0,
      );
    } else {
      return ApiResponse<T>(
        success: true,
        message: response.data?.toString() ?? 'Thao tác thành công',
        data: (response.data as T?),
        statusCode: response.statusCode ?? 200,
      );
    }
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
