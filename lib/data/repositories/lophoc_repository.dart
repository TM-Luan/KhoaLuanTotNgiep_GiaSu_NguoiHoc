// FILE: lophoc_repository.dart
// (Toàn bộ file đã được cập nhật)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';

class LopHocRepository {
  final ApiService _apiService = ApiService();

  // === HÀM getLopHocByTrangThai (Giữ nguyên) ===
  Future<ApiResponse<List<LopHoc>>> getLopHocByTrangThai(
    String trangThai,
  ) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}?trang_thai=$trangThai';

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> lopHocDataList = responseData['data'];

          List<LopHoc> lopHocList = [];
          try {
            lopHocList = lopHocDataList
                .map(
                  (lopHocJson) =>
                      LopHoc.fromJson(lopHocJson as Map<String, dynamic>),
                )
                .toList();
          } catch (e) {
            return ApiResponse<List<LopHoc>>(
              success: false,
              message: 'Lỗi parse dữ liệu lớp học từ API: $e',
              statusCode: response.statusCode,
            );
          }

          return ApiResponse<List<LopHoc>>(
            success: true,
            message: response.message,
            data: lopHocList,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<List<LopHoc>>(
            success: false,
            message:
                "API trả về dữ liệu không đúng định dạng (thiếu key 'data' hoặc không phải List).",
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<List<LopHoc>>(
          success: false,
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Lỗi gọi API hoặc dữ liệu trả về không hợp lệ.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<LopHoc>>(
        success: false,
        message: 'Lỗi không xác định khi lấy danh sách lớp: $e',
        statusCode: 0,
      );
    }
  }

  // === HÀM getLopHocById (Giữ nguyên) ===
  Future<ApiResponse<LopHoc>> getLopHocById(int id) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}/$id';
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> lopHocJson = responseData['data'];
          try {
            final LopHoc lopHoc = LopHoc.fromJson(lopHocJson);
            return ApiResponse<LopHoc>(
              success: true,
              message: response.message,
              data: lopHoc,
              statusCode: response.statusCode,
            );
          } catch (e) {
            return ApiResponse<LopHoc>(
              success: false,
              message: 'Lỗi parse dữ liệu chi tiết lớp học từ API: $e',
              statusCode: response.statusCode,
            );
          }
        } else {
          return ApiResponse<LopHoc>(
            success: false,
            message:
                "API trả về dữ liệu không đúng định dạng (thiếu key 'data' hoặc không phải Object).",
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<LopHoc>(
          success: false,
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Lỗi gọi API chi tiết hoặc dữ liệu trả về không hợp lệ.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<LopHoc>(
        success: false,
        message: 'Lỗi không xác định khi lấy chi tiết lớp: $e',
        statusCode: 0,
      );
    }
  }

  // === HÀM createLopHoc (Giữ nguyên) ===
  Future<ApiResponse<LopHoc>> createLopHoc(
    Map<String, dynamic> lopHocData,
  ) async {
    const String endpoint = ApiConfig.lopHocYeuCau;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint,
        data: lopHocData,
        fromJsonT: (json) => json,
      );
      if (response.statusCode == 201 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;

        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> lopHocJson = responseData['data'];
          try {
            final LopHoc newLopHoc = LopHoc.fromJson(lopHocJson);
            return ApiResponse<LopHoc>(
              success: true,
              message: response.message,
              data: newLopHoc,
              statusCode: response.statusCode,
            );
          } catch (e) {
            return ApiResponse<LopHoc>(
              success: false,
              message: 'Lỗi parse dữ liệu lớp học vừa tạo: $e',
              statusCode: response.statusCode,
            );
          }
        } else {
          return ApiResponse<LopHoc>(
            success: false,
            message:
                "API trả về dữ liệu không đúng định dạng (thiếu key 'data' hoặc không phải Object).",
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<LopHoc>(
          success: false,
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Tạo lớp thất bại.',
          error: response.error,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<LopHoc>(
        success: false,
        message: 'Lỗi không xác định khi tạo lớp: $e',
        statusCode: 0,
      );
    }
  }

  // === HÀM MỚI ĐƯỢC BỔ SUNG NỘI DUNG ===
  // (Gọi API: GET /giasu/lopdangday)
  Future<ApiResponse<List<LopHoc>>> getLopHocDangDayCuaGiaSu() async {
    // Endpoint này đã được định nghĩa trong api_routes_fix.php
    const String endpoint = '/giasu/lopdangday';

    try {
      // 1. Gọi ApiService
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      // 2. Xử lý logic parse
      // Backend trả về collection (LopHocYeuCauResource::collection)
      // nên nó sẽ có key 'data' ở ngoài cùng.
      if (response.isSuccess &&
          response.data != null &&
          response.data!['data'] is List) {
        List<dynamic> lopHocDataList = response.data!['data'];

        List<LopHoc> lopHocList = [];
        try {
          lopHocList = lopHocDataList
              .map((lopHocJson) =>
                  LopHoc.fromJson(lopHocJson as Map<String, dynamic>))
              .toList();
        } catch (e) {
          return ApiResponse<List<LopHoc>>(
            success: false,
            message: 'Lỗi parse dữ liệu lớp học từ API: $e',
            statusCode: response.statusCode,
          );
        }

        return ApiResponse<List<LopHoc>>(
          success: true,
          message: response.message,
          data: lopHocList,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<LopHoc>>(
          success: false,
          message: response.message.isNotEmpty
              ? response.message
              : "API trả về dữ liệu không đúng định dạng (không phải List hoặc không có key 'data').",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<LopHoc>>(
        success: false,
        message: 'Lỗi không xác định khi lấy danh sách lớp: $e',
        statusCode: 0,
      );
    }
  }
}
