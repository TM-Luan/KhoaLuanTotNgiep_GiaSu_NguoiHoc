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
      fromJsonT: (json) => DanhGia.fromJson(json['data'] ?? json),
    );
  }

  /// Lấy danh sách đánh giá của gia sư
  Future<ApiResponse<DanhGiaResponse>> getDanhGiaGiaSu({
    required int giaSuId,
  }) async {
    final endpoint = '/giasu/$giaSuId/danhgia';

    return await _apiService.get(
      endpoint,
      fromJsonT: (json) => DanhGiaResponse.fromJson(json),
    );
  }

  /// Kiểm tra người học đã đánh giá gia sư chưa
  Future<ApiResponse<KiemTraDanhGiaResponse>> kiemTraDaDanhGia({
    required int giaSuId,
  }) async {
    final endpoint = '/giasu/$giaSuId/kiem-tra-danh-gia';

    return await _apiService.get(
      endpoint,
      fromJsonT: (json) => KiemTraDanhGiaResponse.fromJson(json),
    );
  }

  /// Xóa đánh giá
  Future<ApiResponse<dynamic>> xoaDanhGia({
    required int danhGiaId,
  }) async {
    final endpoint = '/danhgia/$danhGiaId';

    return await _apiService.delete(endpoint);
  }
}
