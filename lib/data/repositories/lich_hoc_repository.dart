import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

class LichHocRepository {
  final ApiService _apiService = ApiService();

  Future<LichHocResponse> getLichHocTheoLop(int lopYeuCauId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/lop/$lopYeuCauId/lich-hoc',
      fromJsonT: (json) => json,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    // API trả về data trong response.data['data']
    final responseData = response.data!['data'];
    return LichHocResponse.fromJson(responseData);
  }

  Future<List<LichHoc>> taoLichHocLapLai(
    int lopYeuCauId,
    TaoLichHocRequest request,
  ) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/lop/$lopYeuCauId/lich-hoc-lap-lai',
      data: request.toJson(),
      fromJsonT: (json) => json,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    return (response.data!['data'] as List)
        .map((e) => LichHoc.fromJson(e))
        .toList();
  }

  Future<LichHoc> capNhatLichHoc(
    int lichHocId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '/lich-hoc/$lichHocId',
      data: data,
      fromJsonT: (json) => json,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    return LichHoc.fromJson(response.data!['data']);
  }

  Future<void> xoaLichHoc(int lichHocId, {bool xoaCaChuoi = false}) async {
    final response = await _apiService.delete<Map<String, dynamic>>(
      '/lich-hoc/$lichHocId?xoa_ca_chuoi=$xoaCaChuoi',
      fromJsonT: (json) => json,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }

  Future<LichHoc> taoLichHocDon(
    int lopYeuCauId,
    TaoLichHocRequest request,
  ) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/lop/$lopYeuCauId/lich-hoc',
      data: request.toJson(),
      fromJsonT: (json) => json,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    return LichHoc.fromJson(response.data!['data']);
  }

  // THÊM MỚI: Lấy lịch học theo người học
  Future<List<LichHoc>> getLichHocTheoNguoiHoc({
    String? trangThai,
    String? tuNgay,
    String? denNgay,
  }) async {
    final queryParams = <String, String>{};
    if (trangThai != null) queryParams['trang_thai'] = trangThai;
    if (tuNgay != null) queryParams['tu_ngay'] = tuNgay;
    if (denNgay != null) queryParams['den_ngay'] = denNgay;

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint =
        queryString.isEmpty
            ? ApiConfig.lichHocNguoiHoc
            : '${ApiConfig.lichHocNguoiHoc}?$queryString';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      fromJsonT: (json) => json,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    // API trả về data trong response.data['data']['lich_hoc']
    final responseData = response.data!['data'];
    return (responseData['lich_hoc'] as List)
        .map((e) => LichHoc.fromJson(e))
        .toList();
  }

  // THÊM MỚI: Lấy lịch học theo gia sư
  Future<List<LichHoc>> getLichHocTheoGiaSu({
    String? trangThai,
    String? tuNgay,
    String? denNgay,
  }) async {
    final queryParams = <String, String>{};
    if (trangThai != null) queryParams['trang_thai'] = trangThai;
    if (tuNgay != null) queryParams['tu_ngay'] = tuNgay;
    if (denNgay != null) queryParams['den_ngay'] = denNgay;

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint =
        queryString.isEmpty
            ? ApiConfig.lichHocGiaSu
            : '${ApiConfig.lichHocGiaSu}?$queryString';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      fromJsonT: (json) => json,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    // API trả về data trong response.data['data']['lich_hoc']
    final responseData = response.data!['data'];
    return (responseData['lich_hoc'] as List)
        .map((e) => LichHoc.fromJson(e))
        .toList();
  }
}
