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

  Future<ApiResponse<List<LopHoc>>> getLopHocCuaNguoiHoc() async {
  // Endpoint này đã được định nghĩa trong routes/api.php
  const String endpoint = '/nguoihoc/lopcuatoi';

  try {
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      fromJsonT: (json) => json,
    );
    if (response.isSuccess &&
        response.data != null &&
        response.data!['data'] is List) {
      List<dynamic> dataList = response.data!['data'];

      List<LopHoc> lopHocList = dataList
          .map((item) => LopHoc.fromJson(item as Map<String, dynamic>))
          .toList();

      // Dòng return đã được sửa (thêm message)
      return ApiResponse<List<LopHoc>>(
        success: true,
        message: response.message, // <-- SỬA LỖI NẰM Ở ĐÂY
        data: lopHocList,
        statusCode: response.statusCode,
      );
    } else {
      // Dòng return khi thất bại (đã đúng)
      return ApiResponse<List<LopHoc>>(
        success: false,
        message: response.message.isNotEmpty
            ? response.message
            : "API trả về dữ liệu không đúng định dạng.",
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    // Dòng return khi có exception (đã đúng)
    return ApiResponse<List<LopHoc>>(
      success: false,
      message: 'Lỗi không xác định khi lấy danh sách lớp của bạn: $e',
      statusCode: 0,
    );
  }
}
Future<ApiResponse<LopHoc>> updateLopHoc(
    int classId,
    Map<String, dynamic> lopHocData,
  ) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}/$classId'; // Endpoint: /lophocyeucau/123

    try {
      // Gọi API PUT
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint,
        data: lopHocData,
        fromJsonT: (json) => json,
      );

      // Server trả về 200 (OK) và có key 'data'
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;

        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> lopHocJson = responseData['data'];
          try {
            final LopHoc updatedLopHoc = LopHoc.fromJson(lopHocJson);
            return ApiResponse<LopHoc>(
              success: true,
              message: response.message,
              data: updatedLopHoc,
              statusCode: response.statusCode,
            );
          } catch (e) {
            return ApiResponse<LopHoc>(
              success: false,
              message: 'Lỗi parse dữ liệu lớp học vừa cập nhật: $e',
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
        // Xử lý lỗi từ server (ví dụ: 403 Forbidden, 404 Not Found, 422 Validation)
        return ApiResponse<LopHoc>(
          success: false,
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Cập nhật lớp thất bại.',
          error: response.error,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<LopHoc>(
        success: false,
        message: 'Lỗi không xác định khi cập nhật lớp: $e',
        statusCode: 0,
      );
    }
  }
  Future<ApiResponse<void>> deleteLopHoc(int classId) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}/$classId';
    try {
      final response = await _apiService.delete(endpoint);

      if (response.statusCode == 204) {
        return ApiResponse<void>(
          success: true,
          message: 'Xóa lớp thành công!',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response.message.isNotEmpty
              ? response.message
              : 'Xóa lớp thất bại!',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Lỗi khi xóa lớp: $e',
        statusCode: 0,
      );
    }
  }
}
