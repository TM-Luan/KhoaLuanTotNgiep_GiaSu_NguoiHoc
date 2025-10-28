import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart'; // Import model Tutor

class GiaSuRepository {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<Tutor>>> getDanhSachGiaSu() async {
    const String endpoint = '/giasu';

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.data != null) {
        final Map<String, dynamic> responseData = response.data!;

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> giaSuDataList = responseData['data'];

          List<Tutor> giaSuList = giaSuDataList
              .map((giaSuJson) => Tutor.fromJson(giaSuJson as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Tutor>>(
            success: true,
            message: '',
            data: giaSuList,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<List<Tutor>>(
            success: false,
            message: "API trả về dữ liệu không đúng định dạng (thiếu key 'data').",
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<List<Tutor>>(
          success: false,
          message: response.message.isNotEmpty ? response.message : 'Lỗi gọi API.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<Tutor>>(
        success: false,
        message: 'Lỗi không xác định khi lấy danh sách gia sư: $e',
        statusCode: 0,
      );
    }
  }
}