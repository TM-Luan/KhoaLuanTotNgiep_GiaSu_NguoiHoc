// file: lich_hoc_repository.dart (PHIÊN BẢN ĐÃ SỬA)

import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';

class LichHocRepository {
  final ApiService _apiService = ApiService();

  // [MỚI] Lấy tóm tắt (dấu chấm) cho lịch Gia Sư
  Future<ApiResponse<Set<String>>> getLichHocSummaryGiaSu({
    int? thang,
    int? nam,
  }) async {
    String endpoint = '/giasu/lich-hoc-summary';
    final params = <String, String>{};

    if (thang != null) params['thang'] = thang.toString();
    if (nam != null) params['nam'] = nam.toString();

    if (params.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: params).query}';
    }

    return await _apiService.get(
      endpoint,
      // SỬA 1: 'data' bây giờ là List, không còn là Map
      fromJsonT: (data) {
        final List<dynamic> dataList = data as List;
        return dataList.map((e) => e.toString()).toSet();
      },
    );
  }

  // [MỚI] Lấy chi tiết lịch học theo 1 NGÀY cho Gia Sư
  Future<ApiResponse<List<LichHoc>>> getLichHocTheoNgayGiaSu({
    required DateTime ngay,
  }) async {
    String endpoint = '/giasu/lich-hoc-theo-ngay';
    final params = <String, String>{
      'ngay': DateFormat('yyyy-MM-dd').format(ngay),
    };
    endpoint += '?${Uri(queryParameters: params).query}';

    return await _apiService.get(
      endpoint,
      // SỬA 2: 'data' bây giờ là List
      fromJsonT: (data) {
        final List<dynamic> dataList = data as List;
        return dataList.map((item) => LichHoc.fromJson(item)).toList();
      },
    );
  }

  // [MỚI] Lấy tóm tắt (dấu chấm) cho lịch Người Học
  Future<ApiResponse<Set<String>>> getLichHocSummaryNguoiHoc({
    int? thang,
    int? nam,
  }) async {
    String endpoint = '/nguoihoc/lich-hoc-summary';
    final params = <String, String>{};

    if (thang != null) params['thang'] = thang.toString();
    if (nam != null) params['nam'] = nam.toString();

    if (params.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: params).query}';
    }

    return await _apiService.get(
      endpoint,
      // SỬA 3: 'data' bây giờ là List
      fromJsonT: (data) {
        final List<dynamic> dataList = data as List;
        return dataList.map((e) => e.toString()).toSet();
      },
    );
  }

  // [MỚI] Lấy chi tiết lịch học theo 1 NGÀY cho Người Học
  Future<ApiResponse<List<LichHoc>>> getLichHocTheoNgayNguoiHoc({
    required DateTime ngay,
  }) async {
    String endpoint = '/nguoihoc/lich-hoc-theo-ngay';
    final params = <String, String>{
      'ngay': DateFormat('yyyy-MM-dd').format(ngay),
    };
    endpoint += '?${Uri(queryParameters: params).query}';

    return await _apiService.get(
      endpoint,
      // SỬA 4: 'data' bây giờ là List
      fromJsonT: (data) {
        final List<dynamic> dataList = data as List;
        return dataList.map((item) => LichHoc.fromJson(item)).toList();
      },
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
      // SỬA 5: 'data' bây giờ là Map data
      fromJsonT: (data) => LichHocTheoThangResponse.fromJson(data),
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
      // SỬA 6: 'data' bây giờ là List
      fromJsonT: (data) {
        final dataList = data as List;
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
      // SỬA 7: 'data' bây giờ là Map của LichHoc
      fromJsonT: (data) => LichHoc.fromJson(data),
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