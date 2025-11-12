// FILE: lophoc_repository.dart (ĐÃ SỬA VÀ TỐI ƯU)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';

class LopHocRepository {
  final ApiService _apiService = ApiService();

  /// Lấy lớp học theo trạng thái
  Future<ApiResponse<List<LopHoc>>> getLopHocByTrangThai(
    String trangThai,
  ) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}?trang_thai=$trangThai';
    
    // SỬA: Đơn giản hóa. ApiService tự động mở gói 'data' (là một List)
    return await _apiService.get(
      endpoint,
      fromJsonT: (data) =>
          (data as List).map((item) => LopHoc.fromJson(item)).toList(),
    );
  }

  /// Lấy chi tiết lớp học
  Future<ApiResponse<LopHoc>> getLopHocById(int id) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}/$id';

    // SỬA: ApiService tự động mở gói 'data' (là một Map)
    return await _apiService.get(
      endpoint,
      fromJsonT: (data) => LopHoc.fromJson(data),
    );
  }

  /// Tạo lớp học mới
  Future<ApiResponse<LopHoc>> createLopHoc(
    Map<String, dynamic> lopHocData,
  ) async {
    const String endpoint = ApiConfig.lopHocYeuCau;

    // SỬA: ApiService tự động mở gói 'data' (là một Map)
    return await _apiService.post(
      endpoint,
      data: lopHocData,
      fromJsonT: (data) => LopHoc.fromJson(data),
    );
  }

  /// Lấy các lớp của người học
  Future<ApiResponse<List<LopHoc>>> getLopHocCuaNguoiHoc() async {
    const String endpoint = '/nguoihoc/lopcuatoi';

    // SỬA: ApiService tự động mở gói 'data' (là một List)
    return await _apiService.get(
      endpoint,
      fromJsonT: (data) =>
          (data as List).map((item) => LopHoc.fromJson(item)).toList(),
    );
  }

  /// Cập nhật lớp học
  Future<ApiResponse<LopHoc>> updateLopHoc(
    int classId,
    Map<String, dynamic> lopHocData,
  ) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}/$classId';

    // SỬA: ApiService tự động mở gói 'data' (là một Map)
    return await _apiService.put(
      endpoint,
      data: lopHocData,
      fromJsonT: (data) => LopHoc.fromJson(data),
    );
  }

  /// Xóa lớp học
  Future<ApiResponse<void>> deleteLopHoc(int classId) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}/$classId';
    
    // SỬA: Chuyển đổi kiểu trả về từ ApiService
    final response = await _apiService.delete(endpoint);
    return ApiResponse<void>(
      success: response.success,
      message: response.message,
      statusCode: response.statusCode,
    );
  }
}