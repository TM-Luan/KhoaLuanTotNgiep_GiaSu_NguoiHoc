// FILE: yeu_cau_nhan_lop_repository.dart (ĐÃ SỬA VÀ TỐI ƯU)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop.dart';

class YeuCauNhanLopRepository {
  final ApiService _apiService = ApiService();

  // SỬA: Bỏ hoàn toàn hàm _mapListResponse vì không cần nữa

  /// Lấy danh sách đã gửi
  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachDaGui({
    required int nguoiGuiTaiKhoanId,
  }) async {
    // SỬA: Gọi thẳng ApiService với fromJsonT
    return await _apiService.get(
      '/yeucau/dagui?NguoiGuiTaiKhoanID=$nguoiGuiTaiKhoanId',
      fromJsonT: (data) =>
          (data as List).map((item) => YeuCauNhanLop.fromJson(item)).toList(),
    );
  }

  /// Lấy danh sách nhận được
  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachNhanDuoc({
    required int giaSuId,
  }) async {
    // SỬA: Gọi thẳng ApiService với fromJsonT
    return await _apiService.get(
      '/yeucau/nhanduoc?GiaSuID=$giaSuId',
      fromJsonT: (data) =>
          (data as List).map((item) => YeuCauNhanLop.fromJson(item)).toList(),
    );
  }

  /// Lấy đề nghị theo lớp
  Future<ApiResponse<List<YeuCauNhanLop>>> getDeNghiTheoLop(
    int lopYeuCauId,
  ) async {
    // SỬA: Gọi thẳng ApiService với fromJsonT
    return await _apiService.get(
      '/lophocyeucau/$lopYeuCauId/de-nghi',
      fromJsonT: (data) =>
          (data as List).map((item) => YeuCauNhanLop.fromJson(item)).toList(),
    );
  }

  // === CÁC HÀM POST, PUT, DELETE GIỮ NGUYÊN ===
  // (Vì chúng không dùng fromJsonT nên không bị ảnh hưởng)

  Future<ApiResponse<dynamic>> giaSuGuiYeuCau({
    required int lopId,
    required int giaSuId,
    required int nguoiGuiTaiKhoanId,
    String? ghiChu,
  }) async {
    final data = {
      'LopYeuCauID': lopId,
      'GiaSuID': giaSuId,
      'NguoiGuiTaiKhoanID': nguoiGuiTaiKhoanId,
      'GhiChu': ghiChu,
    };

    return _apiService.post('/giasu/guiyeucau', data: data);
  }

  Future<ApiResponse<dynamic>> nguoiHocMoiGiaSu({
    required int lopId,
    required int giaSuId,
    required int nguoiGuiTaiKhoanId,
    String? ghiChu,
  }) async {
    return _apiService.post(
      '/nguoihoc/moigiasu',
      data: {
        'LopYeuCauID': lopId,
        'GiaSuID': giaSuId,
        'NguoiGuiTaiKhoanID': nguoiGuiTaiKhoanId,
        'GhiChu': ghiChu,
      },
    );
  }

  Future<ApiResponse<dynamic>> capNhatYeuCau({
    required int yeuCauId,
    required int nguoiGuiTaiKhoanId,
    String? ghiChu,
  }) async {
    return _apiService.put(
      '/yeucau/$yeuCauId',
      data: {'NguoiGuiTaiKhoanID': nguoiGuiTaiKhoanId, 'GhiChu': ghiChu},
    );
  }

  Future<ApiResponse<dynamic>> huyYeuCau({
    required int yeuCauId,
    required int nguoiGuiTaiKhoanId,
  }) async {
    return _apiService.delete(
      '/yeucau/$yeuCauId/huy?NguoiGuiTaiKhoanID=$nguoiGuiTaiKhoanId',
    );
  }

  Future<ApiResponse<dynamic>> xacNhanYeuCau(int yeuCauId) async {
    return _apiService.put('/yeucau/$yeuCauId/xacnhan');
  }

  Future<ApiResponse<dynamic>> tuChoiYeuCau(int yeuCauId) async {
    return _apiService.put('/yeucau/$yeuCauId/tuchoi');
  }

  // === HÀM getLopCuaGiaSu GIỮ NGUYÊN ===
  // (Hàm này đã được viết an toàn, logic cũ vẫn chạy đúng với ApiService mới)
  Future<ApiResponse<Map<String, dynamic>>> getLopCuaGiaSu(int giaSuId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/giasu/$giaSuId/lop',
      fromJsonT: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      final actualData = data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data;

      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: response.message,
        data: actualData,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<Map<String, dynamic>>(
      success: false,
      message: response.message,
      error: response.error,
      statusCode: response.statusCode,
    );
  }
}