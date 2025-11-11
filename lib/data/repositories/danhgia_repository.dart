// file: danhgia_repository.dart (ĐÃ SỬA)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/danhgia.dart';

class DanhGiaRepository {
  final ApiService _apiService = ApiService();

  /// Tạo hoặc cập nhật đánh giá
  Future<ApiResponse<DanhGia>> taoDanhGia({
    required int giaSuId,
    required double diemSo,
    String? binhLuan,
  }) async {
    final endpoint = '/danhgia';

    final data = {
      'gia_su_id': giaSuId,
      'diem_so': diemSo,
      if (binhLuan != null) 'binh_luan': binhLuan,
    };

    return await _apiService.post(
      endpoint,
      data: data,
      // SỬA: 'data' (trước đây là 'json') bây giờ là đối tượng DanhGia đã được mở gói
      fromJsonT: (data) => DanhGia.fromJson(data),
    );
  }

  /// Lấy danh sách đánh giá của gia sư
  Future<ApiResponse<DanhGiaResponse>> getDanhGiaGiaSu({
    required int giaSuId,
  }) async {
    final endpoint = '/giasu/$giaSuId/danhgia';

    return await _apiService.get(
      endpoint,
      // SỬA: 'data' (trước đây là 'json') bây giờ là đối tượng data
      // mà DanhGiaResponse.fromJson mong đợi
      fromJsonT: (data) => DanhGiaResponse.fromJson(data),
    );
  }

  /// Kiểm tra người học đã đánh giá gia sư chưa
  Future<ApiResponse<KiemTraDanhGiaResponse>> kiemTraDaDanhGia({
    required int giaSuId,
  }) async {
    final endpoint = '/giasu/$giaSuId/kiem-tra-danh-gia';

    return await _apiService.get(
      endpoint,
      // SỬA: Tương tự như trên, 'data' là đối tượng data đã mở gói
      fromJsonT: (data) => KiemTraDanhGiaResponse.fromJson(data),
    );
  }

  /// Xóa đánh giá
  Future<ApiResponse<dynamic>> xoaDanhGia({
    required int danhGiaId,
  }) async {
    final endpoint = '/danhgia/$danhGiaId';

    // Hàm delete không cần fromJsonT nên không cần sửa
    return await _apiService.delete(endpoint);
  }
}