// // FILE 1: TẠO MODEL LỚP HỌC
// File này định nghĩa đối tượng LopHoc trong app Flutter
// Các tên trường (MaLop, TieuDeLop...) khớp với
// file LopHocYeuCauResource.php (backend) của bạn.

// FILE 1: SỬA LẠI MODEL CHO ĐÚNG VỚI API
// Model này khớp với các key JSON từ LopHocYeuCauResource.php

class LopHoc {
  final int maLop; // API trả về int
  final String tieuDeLop; // API trả về TieuDeLop
  final String tenNguoiHoc; // API trả về TenNguoiHoc
  final String? diaChi;
  final String hocPhi; // API trả về String (đã định dạng)
  final String? moTaChiTiet;

  LopHoc({
    required this.maLop,
    required this.tieuDeLop,
    required this.tenNguoiHoc,
    this.diaChi,
    required this.hocPhi,
    this.moTaChiTiet,
  });

  // Hàm "factory" này rất quan trọng
  // Nó biết cách "đọc" JSON từ API
  factory LopHoc.fromJson(Map<String, dynamic> json) {
    return LopHoc(
      // Key 'MaLop' phải khớp với JSON từ backend
      maLop: json['MaLop'] as int,
      tieuDeLop: json['TieuDeLop'] as String,
      tenNguoiHoc: json['TenNguoiHoc'] as String,
      diaChi: json['DiaChi'] as String?,
      hocPhi: json['HocPhi'] as String,
      moTaChiTiet: json['MoTaChiTiet'] as String?,
    );
  }
}

