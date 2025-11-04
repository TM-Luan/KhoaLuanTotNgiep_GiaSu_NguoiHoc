
import 'package:intl/intl.dart';
class LichHoc {
  final int lichHocID;
  final int lopYeuCauID;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  final String ngayHoc;
  final String trangThai;
  final String? duongDan;
  final String ngayTao;
  
  // Thông tin từ lớp học (join)
  final String? tenLop;
  final String? tenMon;
  final String? tenGiaSu;
  final String? tenNguoiHoc;
  final String? hinhThuc;
  final double? hocPhi;

  LichHoc({
    required this.lichHocID,
    required this.lopYeuCauID,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.ngayHoc,
    required this.trangThai,
    this.duongDan,
    required this.ngayTao,
    this.tenLop,
    this.tenMon,
    this.tenGiaSu,
    this.tenNguoiHoc,
    this.hinhThuc,
    this.hocPhi,
  });

  factory LichHoc.fromJson(Map<String, dynamic> json) {
    return LichHoc(
      lichHocID: json['LichHocID'] ?? 0,
      lopYeuCauID: json['LopYeuCauID'] ?? 0,
      thoiGianBatDau: json['ThoiGianBatDau'] ?? '',
      thoiGianKetThuc: json['ThoiGianKetThuc'] ?? '',
      ngayHoc: json['NgayHoc'] ?? '',
      trangThai: json['TrangThai'] ?? 'SapToi',
      duongDan: json['DuongDan'],
      ngayTao: json['NgayTao'] ?? '',
      tenLop: json['ten_lop'],
      tenMon: json['ten_mon'],
      tenGiaSu: json['ten_gia_su'],
      tenNguoiHoc: json['ten_nguoi_hoc'],
      hinhThuc: json['hinh_thuc'],
      hocPhi: json['hoc_phi'] != null ? double.parse(json['hoc_phi'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LopYeuCauID': lopYeuCauID,
      'ThoiGianBatDau': thoiGianBatDau,
      'ThoiGianKetThuc': thoiGianKetThuc,
      'NgayHoc': ngayHoc,
      'TrangThai': trangThai,
      'DuongDan': duongDan,
    };
  }

  // Helper methods
  bool get isOnline => hinhThuc?.toLowerCase() == 'online';
  bool get isDaHoc => trangThai == 'DaHoc';
  bool get isDangDay => trangThai == 'DangDay';
  bool get isSapToi => trangThai == 'SapToi';
  
  String get formattedTime {
    try {
      final start = thoiGianBatDau.split(' ').last.substring(0, 5);
      final end = thoiGianKetThuc.split(' ').last.substring(0, 5);
      return '$start - $end';
    } catch (e) {
      return '$thoiGianBatDau - $thoiGianKetThuc';
    }
  }

  String get formattedDate {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(ngayHoc));
    } catch (e) {
      return ngayHoc;
    }
  }
}