import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

class LichHocRepository {
  final ApiService _apiService = ApiService();

  // Future<ApiResponse<LichHocTheoThangResponse>> getLichHocTheoThangGiaSu({
  //   int? thang,
  //   int? nam,
  //   int? lopYeuCauId,
  // }) async {
  //   String endpoint = '/giasu/lich-hoc-theo-thang';
  //   final params = <String, String>{};

  //   if (thang != null) params['thang'] = thang.toString();
  //   if (nam != null) params['nam'] = nam.toString();
  //   if (lopYeuCauId != null) params['lop_yeu_cau_id'] = lopYeuCauId.toString();

  //   if (params.isNotEmpty) {
  //     endpoint += '?${Uri(queryParameters: params).query}';
  //   }

  //   return await _apiService.get(
  //     endpoint,
  //     fromJsonT:
  //         (json) => LichHocTheoThangResponse.fromJson(json['data'] ?? json),
  //   );
  // }
  Future<ApiResponse<LichHocTheoThangResponse>> getLichHocTheoThangGiaSu({
    int? thang,
    int? nam,
    int? lopYeuCauId,
  }) async {
    String endpoint = '/giasu/lich-hoc-theo-thang';
    final params = <String, String>{};

    if (thang != null) params['thang'] = thang.toString();
    if (nam != null) params['nam'] = nam.toString();
    if (lopYeuCauId != null) params['lop_yeu_cau_id'] = lopYeuCauId.toString();

    if (params.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: params).query}';
    }

    final response = await _apiService.get(
      endpoint,
      fromJsonT: (json) {
        if (json['data'] != null) {
          // Log chi tiết cấu trúc data
          if (json['data'] is Map) {
            final data = json['data'] as Map<String, dynamic>;
            data.forEach((key, value) {});
          }
        }

        try {
          final parsedData = LichHocTheoThangResponse.fromJson(
            json['data'] ?? json,
          );
          return parsedData;
        } catch (e) {
          if (json['data'] != null) {}
          rethrow;
        }
      },
    );

    return response;
  }

  Future<ApiResponse<LichHocTheoThangResponse>> getLichHocTheoThangNguoiHoc({
    int? thang,
    int? nam,
    int? lopYeuCauId,
  }) async {
    String endpoint = '/nguoihoc/lich-hoc-theo-thang';
    final params = <String, String>{};

    if (thang != null) params['thang'] = thang.toString();
    if (nam != null) params['nam'] = nam.toString();
    if (lopYeuCauId != null) params['lop_yeu_cau_id'] = lopYeuCauId.toString();

    if (params.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: params).query}';
    }

    return await _apiService.get(
      endpoint,
      fromJsonT:
          (json) => LichHocTheoThangResponse.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<LichHocTheoThangResponse>> getLichHocTheoLopVaThang({
    required int lopYeuCauId,
    int? thang,
    int? nam,
  }) async {
    String endpoint = '/lop/$lopYeuCauId/lich-hoc-theo-thang';
    final params = <String, String>{};

    if (thang != null) params['thang'] = thang.toString();
    if (nam != null) params['nam'] = nam.toString();

    if (params.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: params).query}';
    }

    return await _apiService.get(
      endpoint,
      fromJsonT:
          (json) => LichHocTheoThangResponse.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<List<LichHoc>>> taoLichHocLapLai({
    required int lopYeuCauId,
    required String thoiGianBatDau,
    required String thoiGianKetThuc,
    required String ngayHoc,
    required bool lapLai,
    int soTuanLap = 1,
    String? duongDan,
    String trangThai = 'SapToi',
  }) async {
    final endpoint = '/lop/$lopYeuCauId/lich-hoc-lap-lai';

    final data = {
      'ThoiGianBatDau': thoiGianBatDau,
      'ThoiGianKetThuc': thoiGianKetThuc,
      'NgayHoc': ngayHoc,
      'LapLai': lapLai,
      'SoTuanLap': soTuanLap,
      'DuongDan': duongDan,
      'TrangThai': trangThai,
    };

    return await _apiService.post(
      endpoint,
      data: data,
      fromJsonT: (json) {
        final dataList = json['data'] as List;
        return dataList.map((item) => LichHoc.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<LichHoc>> capNhatLichHoc({
    required int lichHocId,
    String? thoiGianBatDau,
    String? thoiGianKetThuc,
    String? ngayHoc,
    String? duongDan,
    String? trangThai,
  }) async {
    final endpoint = '/lich-hoc/$lichHocId';

    final body = <String, dynamic>{};
    if (thoiGianBatDau != null) body['ThoiGianBatDau'] = thoiGianBatDau;
    if (thoiGianKetThuc != null) body['ThoiGianKetThuc'] = thoiGianKetThuc;
    if (ngayHoc != null) body['NgayHoc'] = ngayHoc;
    if (duongDan != null) body['DuongDan'] = duongDan;
    if (trangThai != null) body['TrangThai'] = trangThai;

    return await _apiService.put(
      endpoint,
      data: body,
      fromJsonT: (json) => LichHoc.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<dynamic>> xoaLichHoc({
    required int lichHocId,
    bool xoaCaChuoi = false,
  }) async {
    String endpoint = '/lich-hoc/$lichHocId';

    if (xoaCaChuoi) {
      endpoint += '?xoa_ca_chuoi=true';
    }

    return await _apiService.delete(endpoint);
  }
}
