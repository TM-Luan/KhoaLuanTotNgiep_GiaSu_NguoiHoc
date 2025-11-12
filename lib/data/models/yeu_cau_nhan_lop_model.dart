import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';

class YeuCauNhanLop {
  final int yeuCauID;
  final int lopYeuCauID;
  final int? giaSuID;
  final int? nguoiGuiTaiKhoanID;
  final String trangThai;
  final String vaiTroNguoiGui;
  final String? ghiChu;
  final String? ngayTao;
  final String? ngayCapNhat;
  final String? nguoiGuiHoTen;
  final String? giaSuHoTen;
  final LopHoc lopHoc;

  const YeuCauNhanLop({
    required this.yeuCauID,
    required this.lopYeuCauID,
    required this.giaSuID,
    required this.nguoiGuiTaiKhoanID,
    required this.trangThai,
    required this.vaiTroNguoiGui,
    this.ghiChu,
    this.ngayTao,
    this.ngayCapNhat,
    this.nguoiGuiHoTen,
    this.giaSuHoTen,
    required this.lopHoc,
  });

  bool get isPending => trangThai == 'Pending';
  bool get isAccepted => trangThai == 'Accepted';

  factory YeuCauNhanLop.fromJson(Map<String, dynamic> json) {
    final lopHocData = json['lop_yeu_cau'] ?? json['lop'];

    LopHoc lopHoc;
    if (lopHocData != null && lopHocData is Map<String, dynamic>) {
      lopHoc = LopHoc.fromJson(lopHocData);
    } else {
      lopHoc = LopHoc.fromJson(json);
    }

    final nguoiGui = json['NguoiGui'];
    final giaSu = json['GiaSu'];

    return YeuCauNhanLop(
      yeuCauID: json['YeuCauID'] ?? 0,
      lopYeuCauID: json['LopYeuCauID'] ?? lopHoc.maLop,
      giaSuID: json['GiaSuID'],
      nguoiGuiTaiKhoanID: json['NguoiGuiTaiKhoanID'],
      trangThai: json['TrangThai'] ?? '',
      vaiTroNguoiGui: json['VaiTroNguoiGui'] ?? '',
      ghiChu: json['GhiChu']?.toString(),
      ngayTao: json['NgayTao']?.toString(),
      ngayCapNhat: json['NgayCapNhat']?.toString(),
      nguoiGuiHoTen:
          nguoiGui is Map<String, dynamic> ? nguoiGui['HoTen']?.toString() : null,
      giaSuHoTen:
          giaSu is Map<String, dynamic> ? giaSu['HoTen']?.toString() : null,
      lopHoc: lopHoc,
    );
  }
}
