import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop_model.dart';

class YeuCauNhanLopRepository {
  final ApiService _apiService = ApiService();

  /// Lấy danh sách yêu cầu đã gửi
  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachDaGui({
    required int nguoiGuiTaiKhoanId,
  }) async {
    return await _apiService.get(
      '/yeucau/dagui?NguoiGuiTaiKhoanID=$nguoiGuiTaiKhoanId',
      fromJsonT:
          (data) =>
              (data as List)
                  .map((item) => YeuCauNhanLop.fromJson(item))
                  .toList(),
    );
  }

  /// Lấy danh sách yêu cầu nhận được
  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachNhanDuoc({
    required int giaSuId,
  }) async {
    return await _apiService.get(
      '/yeucau/nhanduoc?GiaSuID=$giaSuId',
      fromJsonT:
          (data) =>
              (data as List)
                  .map((item) => YeuCauNhanLop.fromJson(item))
                  .toList(),
    );
  }

  /// Lấy danh sách đề nghị theo lớp
  Future<ApiResponse<List<YeuCauNhanLop>>> getDeNghiTheoLop(
    int lopYeuCauId,
  ) async {
    return await _apiService.get(
      '/lophocyeucau/$lopYeuCauId/de-nghi',
      fromJsonT:
          (data) =>
              (data as List)
                  .map((item) => YeuCauNhanLop.fromJson(item))
                  .toList(),
    );
  }

  /// Gia sư gửi yêu cầu nhận lớp
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

  /// Người học mời gia sư
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

  /// Cập nhật nội dung yêu cầu
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

  /// Hủy yêu cầu
  Future<ApiResponse<dynamic>> huyYeuCau({
    required int yeuCauId,
    required int nguoiGuiTaiKhoanId,
  }) async {
    return _apiService.delete(
      '/yeucau/$yeuCauId/huy?NguoiGuiTaiKhoanID=$nguoiGuiTaiKhoanId',
    );
  }

  /// Xác nhận yêu cầu (Chấp nhận)
  Future<ApiResponse<dynamic>> xacNhanYeuCau(int yeuCauId) async {
    return _apiService.put('/yeucau/$yeuCauId/xacnhan');
  }

  /// Từ chối yêu cầu
  Future<ApiResponse<dynamic>> tuChoiYeuCau(int yeuCauId) async {
    return _apiService.put('/yeucau/$yeuCauId/tuchoi');
  }

  /// [QUAN TRỌNG] Hàm hoàn thành lớp học cho Gia sư
  Future<ApiResponse<dynamic>> hoanThanhLop(int lopId) async {
    // Gọi API cập nhật trạng thái lớp thành 'DaKetThuc' hoặc tương tự
    return await _apiService.put('/lophocyeucau/$lopId/hoanthanh');
  }

  /// Lấy danh sách các lớp của Gia sư (Đang dạy, Đã dạy, Lời mời)
  Future<ApiResponse<Map<String, dynamic>>> getLopCuaGiaSu(int giaSuId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/giasu/$giaSuId/lop',
      fromJsonT: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      // Xử lý trường hợp API trả về data lồng nhau
      final actualData =
          data.containsKey('data')
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
