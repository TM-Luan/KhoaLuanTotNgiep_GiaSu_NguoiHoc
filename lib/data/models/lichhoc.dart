// lichhoc.dart
class LichHoc {
  final int? lichHocID;
  final int lopYeuCauID;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  final String ngayHoc;
  final String? duongDan;
  final String trangThai;
  final bool isLapLai;
  final int? lichHocGocID;
  final List<LichHoc>? lichHocCon;

  LichHoc({
    this.lichHocID,
    required this.lopYeuCauID,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.ngayHoc,
    this.duongDan,
    this.trangThai = 'SapToi',
    required this.isLapLai, // THAY ĐỔI: bỏ giá trị mặc định
    this.lichHocGocID,
    this.lichHocCon,
  });

  factory LichHoc.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing LichHoc from JSON: $json');

    // Hàm parse bool an toàn
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    // Hàm parse int an toàn
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Hàm parse string an toàn
    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return LichHoc(
      lichHocID: parseInt(json['LichHocID']),
      lopYeuCauID: parseInt(json['LopYeuCauID']) ?? 0,
      thoiGianBatDau: parseString(json['ThoiGianBatDau']),
      thoiGianKetThuc: parseString(json['ThoiGianKetThuc']),
      ngayHoc: parseString(json['NgayHoc']),
      duongDan: json['DuongDan']?.toString(),
      trangThai: parseString(json['TrangThai']),
      isLapLai: parseBool(json['IsLapLai']),
      lichHocGocID: parseInt(json['LichHocGocID']),
      lichHocCon:
          json['lich_hoc_con'] != null
              ? (json['lich_hoc_con'] as List)
                  .map((e) => LichHoc.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (lichHocID != null) 'LichHocID': lichHocID,
      'LopYeuCauID': lopYeuCauID,
      'ThoiGianBatDau': thoiGianBatDau,
      'ThoiGianKetThuc': thoiGianKetThuc,
      'NgayHoc': ngayHoc,
      if (duongDan != null) 'DuongDan': duongDan,
      'TrangThai': trangThai,
      'IsLapLai': isLapLai ? 1 : 0, // CHUYỂN THÀNH INT KHI GỬI LÊN SERVER
      if (lichHocGocID != null) 'LichHocGocID': lichHocGocID,
    };
  }

  LichHoc copyWith({
    int? lichHocID,
    int? lopYeuCauID,
    String? thoiGianBatDau,
    String? thoiGianKetThuc,
    String? ngayHoc,
    String? duongDan,
    String? trangThai,
    bool? isLapLai,
    int? lichHocGocID,
    List<LichHoc>? lichHocCon,
  }) {
    return LichHoc(
      lichHocID: lichHocID ?? this.lichHocID,
      lopYeuCauID: lopYeuCauID ?? this.lopYeuCauID,
      thoiGianBatDau: thoiGianBatDau ?? this.thoiGianBatDau,
      thoiGianKetThuc: thoiGianKetThuc ?? this.thoiGianKetThuc,
      ngayHoc: ngayHoc ?? this.ngayHoc,
      duongDan: duongDan ?? this.duongDan,
      trangThai: trangThai ?? this.trangThai,
      isLapLai: isLapLai ?? this.isLapLai,
      lichHocGocID: lichHocGocID ?? this.lichHocGocID,
      lichHocCon: lichHocCon ?? this.lichHocCon,
    );
  }
}

class LichHocResponse {
  final List<LichHoc> lichHoc;
  final int tongSoBuoi;
  final int tongSoChuoi;

  LichHocResponse({
    required this.lichHoc,
    required this.tongSoBuoi,
    required this.tongSoChuoi,
  });

  factory LichHocResponse.fromJson(Map<String, dynamic> json) {
    return LichHocResponse(
      lichHoc:
          (json['lich_hoc'] as List).map((e) => LichHoc.fromJson(e)).toList(),
      tongSoBuoi: json['tong_so_buoi'] ?? 0,
      tongSoChuoi: json['tong_so_chuoi'] ?? 0,
    );
  }
}

class TaoLichHocRequest {
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  final String ngayHoc;
  final String? duongDan;
  final String? trangThai;
  final bool lapLai;
  final int? soTuanLap;

  TaoLichHocRequest({
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.ngayHoc,
    this.duongDan,
    this.trangThai,
    required this.lapLai,
    this.soTuanLap,
  });

  Map<String, dynamic> toJson() {
    return {
      'ThoiGianBatDau': thoiGianBatDau,
      'ThoiGianKetThuc': thoiGianKetThuc,
      'NgayHoc': ngayHoc,
      if (duongDan != null) 'DuongDan': duongDan,
      if (trangThai != null) 'TrangThai': trangThai,
      'LapLai': lapLai,
      if (lapLai && soTuanLap != null) 'SoTuanLap': soTuanLap,
    };
  }
}
