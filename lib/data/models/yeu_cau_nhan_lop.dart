import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';

class YeuCauNhanLop {
  final int yeuCauID;
  final String trangThai; // "Pending", "Accepted", ...
  final String vaiTroNguoiGui; // "GiaSu" hoặc "NguoiHoc"
  final String? ghiChu;
  final String? ngayTao;
  final LopHoc lopHoc; // ✅ lớp học liên quan

  YeuCauNhanLop({
    required this.yeuCauID,
    required this.trangThai,
    required this.vaiTroNguoiGui,
    this.ghiChu,
    this.ngayTao,
    required this.lopHoc,
  });

  factory YeuCauNhanLop.fromJson(Map<String, dynamic> json) {
  // Nếu có object lồng
  final lopHocData = json['lop_yeu_cau'] ?? json['lop'];

  LopHoc lopHoc;
  if (lopHocData != null && lopHocData is Map<String, dynamic>) {
    lopHoc = LopHoc.fromJson(lopHocData);
  } else {
    // Nếu dữ liệu lớp nằm trực tiếp trong object (như ví dụ bạn gửi)
    lopHoc = LopHoc.fromJson(json);
  }

  return YeuCauNhanLop(
    yeuCauID: json['YeuCauID'] ?? 0,
    trangThai: json['TrangThai'] ?? '',
    vaiTroNguoiGui: json['VaiTroNguoiGui'] ?? '',
    ghiChu: json['GhiChu']?.toString(),
    ngayTao: json['NgayTao']?.toString(),
    lopHoc: lopHoc,
  );
}

}
