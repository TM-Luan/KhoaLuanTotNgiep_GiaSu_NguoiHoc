// file: lichhoc.dart (PHIÊN BẢN ĐÃ SỬA)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';

class LichHoc {
  final int lichHocID;
  final int lopYeuCauID;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  final String ngayHoc;
  final String trangThai;
  final String? duongDan;
  final bool isLapLai;
  final int? lichHocGocID;
  final LopHoc? lopHoc;
  final List<LichHoc>? lichHocCon;

  LichHoc({
    required this.lichHocID,
    required this.lopYeuCauID,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.ngayHoc,
    required this.trangThai,
    this.duongDan,
    required this.isLapLai,
    this.lichHocGocID,
    this.lopHoc,
    this.lichHocCon,
  });

  factory LichHoc.fromJson(Map<String, dynamic> json) {
    // Hàm parse an toàn cho boolean
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    // Hàm parse an toàn cho số nguyên
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Hàm parse an toàn cho số nguyên có thể null
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed == 0 ? null : parsed;
      }
      return null;
    }

    // Xử lý lichHocCon an toàn
    List<LichHoc>? parseLichHocCon(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        try {
          return value.map((item) => LichHoc.fromJson(item)).toList();
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Xử lý lopHoc an toàn
    LopHoc? parseLopHoc(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) {
        try {
          return LopHoc.fromJson(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return LichHoc(
      lichHocID: parseInt(json['LichHocID']),
      lopYeuCauID: parseInt(json['LopYeuCauID']),
      thoiGianBatDau: json['ThoiGianBatDau']?.toString() ?? '',
      thoiGianKetThuc: json['ThoiGianKetThuc']?.toString() ?? '',
      ngayHoc: json['NgayHoc']?.toString() ?? '',
      trangThai: json['TrangThai']?.toString() ?? 'SapToi',
      duongDan: json['DuongDan']?.toString(),
      isLapLai: parseBool(json['IsLapLai']),
      lichHocGocID: parseNullableInt(json['LichHocGocID']),
      
      // SỬA LỖI: Ưu tiên parse 'Lop' (từ Resource), 
      // nếu không có thì dùng 'lop_hoc_yeu_cau' (dự phòng)
      lopHoc: parseLopHoc(json['Lop'] ?? json['lop_hoc_yeu_cau']),
      
      lichHocCon: parseLichHocCon(json['lich_hoc_con']),
    );
  }

  // Thêm method để debug
  Map<String, dynamic> toDebugMap() {
    return {
      'lichHocID': lichHocID,
      'lopYeuCauID': lopYeuCauID,
      'thoiGianBatDau': thoiGianBatDau,
      'thoiGianKetThuc': thoiGianKetThuc,
      'ngayHoc': ngayHoc,
      'trangThai': trangThai,
      'duongDan': duongDan,
      'isLapLai': isLapLai,
      'lichHocGocID': lichHocGocID,
      'hasLopHoc': lopHoc != null,
      'lichHocConCount': lichHocCon?.length ?? 0,
    };
  }
}

class LichHocTheoThangResponse {
  final Map<String, List<LichHoc>> lichHocTheoNgay;
  final ThongKeThang? thongKeThang;
  final List<LopHoc> lopHocTrongThang;
  final int thang;
  final int nam;

  LichHocTheoThangResponse({
    required this.lichHocTheoNgay,
    this.thongKeThang,
    required this.lopHocTrongThang,
    required this.thang,
    required this.nam,
  });

  factory LichHocTheoThangResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý lich_hoc_theo_ngay an toàn
      final lichHocTheoNgayData =
          json['lich_hoc_theo_ngay'] as Map<String, dynamic>? ?? {};
      final lichHocTheoNgay = <String, List<LichHoc>>{};

      lichHocTheoNgayData.forEach((key, value) {
        if (value is List) {
          final lichHocList = <LichHoc>[];
          for (var item in value) {
            {
              final lichHoc = LichHoc.fromJson(item);
              lichHocList.add(lichHoc);
            }
          }
          lichHocTheoNgay[key] = lichHocList;
        }
      });

      // Xử lý thong_ke_thang an toàn (có thể null)
      final thongKeData = json['thong_ke_thang'] as Map<String, dynamic>?;
      final thongKeThang =
          thongKeData != null ? ThongKeThang.fromJson(thongKeData) : null;

      // Xử lý lop_hoc_trong_thang an toàn
      // SỬA: Key có thể là 'lop_hoc_trong_thang' (từ API cũ) 
      // hoặc 'lop_hoc' (từ API /lop/{id}/lich-hoc-theo-thang)
      final dynamic lopHocDataRaw = json['lop_hoc_trong_thang'] ?? json['lop_hoc'];
      final lopHocTrongThang = <LopHoc>[];

      // Xử lý cả 2 trường hợp: List (từ getLichHocTheoThang) 
      // hoặc Map (từ getLichHocTheoLopVaThang)
      if (lopHocDataRaw is List<dynamic>) {
         for (var item in lopHocDataRaw) {
          {
            final lopHoc = LopHoc.fromJson(item);
            lopHocTrongThang.add(lopHoc);
          }
        }
      } else if (lopHocDataRaw is Map<String, dynamic>) {
        // Đây là trường hợp API getLichHocTheoLopVaThang
        lopHocTrongThang.add(LopHoc.fromJson(lopHocDataRaw));
      }

      // Xử lý thang và nam an toàn
      int safeParseMonthYear(dynamic value) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      final thang = safeParseMonthYear(json['thang']);
      final nam = safeParseMonthYear(json['nam']);
      return LichHocTheoThangResponse(
        lichHocTheoNgay: lichHocTheoNgay,
        thongKeThang: thongKeThang,
        lopHocTrongThang: lopHocTrongThang,
        thang: thang,
        nam: nam,
      );
    } catch (e) {
      // Trả về response rỗng để tránh crash
      return LichHocTheoThangResponse(
        lichHocTheoNgay: {},
        thongKeThang: null,
        lopHocTrongThang: [],
        thang: DateTime.now().month,
        nam: DateTime.now().year,
      );
    }
  }

  // Thêm method để debug
  Map<String, dynamic> toDebugMap() {
    return {
      'soNgayCoLich': lichHocTheoNgay.length,
      'tongSoBuoi': thongKeThang?.tongSoBuoi ?? 0,
      'soLopTrongThang': lopHocTrongThang.length,
      'thang': thang,
      'nam': nam,
      'chiTietThongKe': {
        'sapToi': thongKeThang?.sapToi ?? 0,
        'dangDay': thongKeThang?.dangDay ?? 0,
        'daHoc': thongKeThang?.daHoc ?? 0,
        'huy': thongKeThang?.huy ?? 0,
      },
    };
  }
}

class ThongKeThang {
  final int tongSoBuoi;
  final int sapToi;
  final int dangDay;
  final int daHoc;
  final int huy;

  ThongKeThang({
    required this.tongSoBuoi,
    required this.sapToi,
    required this.dangDay,
    required this.daHoc,
    required this.huy,
  });

  factory ThongKeThang.fromJson(Map<String, dynamic> json) {
    // Hàm parse an toàn cho số
    int safeParse(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is bool) return value ? 1 : 0;
      return 0;
    }

    return ThongKeThang(
      tongSoBuoi: safeParse(json['tong_so_buoi']),
      sapToi: safeParse(json['sap_toi']),
      dangDay: safeParse(json['dang_day']),
      daHoc: safeParse(json['da_hoc']),
      huy: safeParse(json['huy']),
    );
  }
}