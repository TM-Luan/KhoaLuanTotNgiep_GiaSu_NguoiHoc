import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop.dart';

class YeuCauNhanLopRepository {
  final ApiService _apiService = ApiService();

  // API 1: Gia sư xem các yêu cầu MÌNH ĐÃ GỬI (để Hủy)
  // GET /yeucau/dagui
  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachDaGui() async {
    const String endpoint = '/yeucau/dagui'; // Khớp với routes/api.php
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.isSuccess && response.data != null && response.data!['data'] is List) {
        List<dynamic> dataList = response.data!['data'];
        List<YeuCauNhanLop> yeuCauList = dataList
            .map((item) => YeuCauNhanLop.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return ApiResponse<List<YeuCauNhanLop>>(
          success: true,
          message: response.message,
          data: yeuCauList,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<YeuCauNhanLop>>(
          success: false,
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<YeuCauNhanLop>>(
        success: false,
        message: 'Lỗi parse getDanhSachDaGui: $e',
        statusCode: 0,
      );
    }
  }

  // API 2: Gia sư xem các lời MỜI TỪ NGƯỜI HỌC (để Xác nhận/Từ chối)
  // GET /yeucau/nhanduoc
  Future<ApiResponse<List<YeuCauNhanLop>>> getDanhSachNhanDuoc() async {
    const String endpoint = '/yeucau/nhanduoc'; // Khớp với routes/api.php
    
    // Logic parse tương tự getDanhSachDaGui
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.isSuccess && response.data != null && response.data!['data'] is List) {
        List<dynamic> dataList = response.data!['data'];
        List<YeuCauNhanLop> yeuCauList = dataList
            .map((item) => YeuCauNhanLop.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return ApiResponse<List<YeuCauNhanLop>>(
          success: true,
          message: response.message,
          data: yeuCauList,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<YeuCauNhanLop>>(
          success: false,
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<YeuCauNhanLop>>(
        success: false,
        message: 'Lỗi parse getDanhSachNhanDuoc: $e',
        statusCode: 0,
      );
    }
  }

  // API 3: Hủy yêu cầu (khi VaiTroNguoiGui == 'GiaSu')
  // DELETE /yeucau/{yeuCauID}/huy
  Future<ApiResponse<dynamic>> huyYeuCau(int yeuCauId) async {
    // Dùng DELETE vì routes/api.php dùng Route::delete
    return await _apiService.delete('/yeucau/$yeuCauId/huy');
  }

  // API 4: Xác nhận yêu cầu (khi VaiTroNguoiGui == 'NguoiHoc')
  // PUT /yeucau/{yeuCauID}/xacnhan
  Future<ApiResponse<dynamic>> xacNhanYeuCau(int yeuCauId) async {
    // Dùng PUT vì routes/api.php dùng Route::put
    return await _apiService.put('/yeucau/$yeuCauId/xacnhan');
  }

  // API 5: Từ chối yêu cầu (khi VaiTroNguoiGui == 'NguoiHoc')
  // PUT /yeucau/{yeuCauID}/tuchoi
  Future<ApiResponse<dynamic>> tuChoiYeuCau(int yeuCauId) async {
    // Dùng PUT vì routes/api.php dùng Route::put
    return await _apiService.put('/yeucau/$yeuCauId/tuchoi');
  }

  // API 6: Gia sư gửi đề nghị dạy
  // POST /giasu/guiyeucau
  Future<ApiResponse<dynamic>> giaSuGuiYeuCau(int lopId, String? ghiChu) async {
    return await _apiService.post(
      '/giasu/guiyeucau',
      data: {
        'lop_yeu_cau_id': lopId,
        'ghi_chu': ghiChu,
      },
    );
  }
}
