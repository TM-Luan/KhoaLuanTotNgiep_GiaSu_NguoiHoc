
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giao_dich_model.dart';

class GiaoDichRepository {
  // Sử dụng ApiService singleton
  final ApiService _apiService = ApiService();

  /// Hàm tạo một giao dịch mới
  ///
  /// [requestData] là model chứa thông tin cần gửi lên server
  Future<ApiResponse<GiaoDichModel>> createGiaoDich(
      GiaoDichModel requestData) async {
    // ApiService đã tự động xử lý try-catch cho các lỗi Dio (mạng, 4xx, 5xx)
    // và trả về một ApiResponse chuẩn hóa.
    
    final ApiResponse<GiaoDichModel> response =
        await _apiService.post<GiaoDichModel>(
      ApiConfig.taoGiaoDich, // Endpoint từ api_config.dart
      data: requestData.toJson(), // Dùng hàm toJson của model
      
      // Cung cấp hàm để ApiService biết cách parse JSON thành GiaoDichModel
      fromJsonT: (dynamic json) =>
          GiaoDichModel.fromJson(json as Map<String, dynamic>),
    );

    // Chỉ cần trả về response, ApiService đã xử lý lỗi rồi.
    return response;
  }
}