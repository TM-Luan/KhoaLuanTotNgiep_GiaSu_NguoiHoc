import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giao_dich_model.dart';

class GiaoDichRepository {
  final ApiService _apiService = ApiService();

  // Hàm tạo giao dịch thường (giữ nguyên)
  Future<ApiResponse<GiaoDichModel>> createGiaoDich(
    GiaoDichModel requestData,
  ) async {
    return await _apiService.post<GiaoDichModel>(
      ApiConfig.taoGiaoDich,
      data: requestData.toJson(),
      fromJsonT: (json) => GiaoDichModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // [MỚI] Hàm lấy URL thanh toán VNPay
  Future<ApiResponse<String>> createVnPayUrl({
    required int lopYeuCauId,
    required double soTien,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.vnPayCreateUrl,
        data: {'LopYeuCauID': lopYeuCauId, 'SoTien': soTien},
        fromJsonT: (json) => json,
        unpackData:
            false, // API này trả về payment_url ở root hoặc data tùy backend, ta lấy raw để xử lý
      );

      if (response.success && response.data != null) {
        // Giả sử backend trả về { "success": true, "payment_url": "..." }
        // Hoặc { "success": true, "data": { "payment_url": "..." } }
        // Bạn cần kiểm tra log response thực tế.
        // Ở đây tôi xử lý trường hợp payment_url nằm ngay trong data.

        final data = response.data!;
        String? url;

        if (data.containsKey('payment_url')) {
          url = data['payment_url'];
        } else if (data.containsKey('data') && data['data'] is Map) {
          url = data['data']['payment_url'];
        }

        if (url != null) {
          return ApiResponse(
            success: true,
            message: 'Lấy link thành công',
            data: url,
            statusCode: response.statusCode,
          );
        }
      }

      return ApiResponse(
        success: false,
        message:
            response.message.isNotEmpty
                ? response.message
                : 'Không lấy được link thanh toán',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi repository: $e',
        statusCode: 500,
      );
    }
  }
}
