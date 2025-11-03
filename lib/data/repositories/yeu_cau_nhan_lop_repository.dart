import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop.dart';

class YeuCauNhanLopRepository {
  final ApiService _apiService = ApiService();

  ApiResponse<List<YeuCauNhanLop>> _mapListResponse(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    if (response.isSuccess && response.data != null) {
      final dynamic raw = response.data!['data'];
      if (raw is List) {
        final list = raw
            .whereType<Map<String, dynamic>>()
            .map(YeuCauNhanLop.fromJson)
            .toList();

        return ApiResponse<List<YeuCauNhanLop>>(
          success: true,
          message: response.message,
          data: list,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<List<YeuCauNhanLop>>(
        success: false,
        message: 'Dữ liệu trả về không đúng định dạng.',
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<List<YeuCauNhanLop>>(
      success: false,
      message: response.message,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachDaGui({
    required int nguoiGuiTaiKhoanId,
  }) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/yeucau/dagui?NguoiGuiTaiKhoanID=$nguoiGuiTaiKhoanId',
      fromJsonT: (json) => json,
    );

    return _mapListResponse(response);
  }

  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachNhanDuoc({
    required int giaSuId,
  }) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/yeucau/nhanduoc?GiaSuID=$giaSuId',
      fromJsonT: (json) => json,
    );

    return _mapListResponse(response);
  }

  Future<ApiResponse<List<YeuCauNhanLop>>> getDeNghiTheoLop(int lopYeuCauId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/lophocyeucau/$lopYeuCauId/de-nghi',
      fromJsonT: (json) => json,
    );

    return _mapListResponse(response);
  }

  Future<ApiResponse<dynamic>> giaSuGuiYeuCau({
    required int lopId,
    required int giaSuId,
    required int nguoiGuiTaiKhoanId,
    String? ghiChu,
  }) async {
    print('📤 YeuCauNhanLopRepository.giaSuGuiYeuCau:');
    print('   lopId: $lopId');
    print('   giaSuId: $giaSuId');
    print('   nguoiGuiTaiKhoanId: $nguoiGuiTaiKhoanId');
    print('   ghiChu: "$ghiChu"');
    
    final data = {
      'LopYeuCauID': lopId,
      'GiaSuID': giaSuId,
      'NguoiGuiTaiKhoanID': nguoiGuiTaiKhoanId,
      'GhiChu': ghiChu,
    };
    
    print('📤 Final data to send: $data');
    
    return _apiService.post(
      '/giasu/guiyeucau',
      data: data,
    );
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
      data: {
        'NguoiGuiTaiKhoanID': nguoiGuiTaiKhoanId,
        'GhiChu': ghiChu,
      },
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

  // Lấy danh sách lớp của gia sư (bao gồm cả đang dạy và đề nghị)
  Future<ApiResponse<Map<String, dynamic>>> getLopCuaGiaSu(int giaSuId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/giasu/$giaSuId/lop',
      fromJsonT: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      // API trả về structure: { success: true, message: "...", data: { lopDangDay: [...], lopDeNghi: [...] } }
      final data = response.data!;
      print('Raw API response: $data'); // Debug log
      
      // Kiểm tra xem có field 'data' không, nếu có thì lấy, nếu không thì dùng trực tiếp
      final actualData = data.containsKey('data') ? data['data'] as Map<String, dynamic> : data;
      print('Processed data: $actualData'); // Debug log
      
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
