import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Bắt buộc có import này
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
        connectTimeout: ApiConfig.connectTimeout,
        headers: ApiConfig.headers,
      ),
    );

    // === ⭐️ CẤU HÌNH SỬA LỖI KẾT NỐI (BẢN MẠNH NHẤT) ⭐️ ===
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        // QUAN TRỌNG: Đặt thời gian giữ kết nối nhàn rỗi về 0.
        // Điều này đồng nghĩa với việc TẮT Keep-Alive.
        // Mỗi request sẽ dùng một kết nối mới -> Tránh hoàn toàn lỗi "Unexpected response".
        client.idleTimeout = Duration.zero;

        // Giới hạn số kết nối đồng thời để giảm tải cho Emulator
        client.maxConnectionsPerHost = 5;

        return client;
      },
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

  // ... (Các hàm get, post, put, delete GIỮ NGUYÊN như cũ) ...

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

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJsonT,
    bool unpackData,
  ) {
    if (response.data is Map<String, dynamic>) {
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
      case DioExceptionType.connectionError:
        // Sửa lỗi hiển thị khi mất mạng
        return ApiResponse<T>(
          success: false,
          message: 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.',
          statusCode: 0,
        );
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
