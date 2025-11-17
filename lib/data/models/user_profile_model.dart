// user_profile_model.dart

import 'dart:io';

class UserProfile {
  int? taiKhoanID;
  String? email;
  String? hoTen;
  String? soDienThoai;
  int? vaiTro; // 1: Admin, 2: GiaSu, 3: NguoiHoc
  int? trangThai;
  String? diaChi;
  String? gioiTinh;
  String? ngaySinh;
  String? anhDaiDien;

  int? nguoiHocID;

  // Trường của Gia Sư
  int? giaSuID;
  String? bangCap;
  String? kinhNghiem;
  String? anhCCCDMatTruoc;
  String? anhCCCDMatSau;
  String? anhBangCap;
  String? truongDaoTao;
  String? chuyenNganh;
  String? thanhTich;

  // ⭐️ THAY ĐỔI: Từ List<DropdownItem> sang int? và String?
  int? monID;
  String? tenMon; // Để hiển thị ở ProfileScreen

  // ⭐️ THÊM: Các trường File để lưu ảnh TẠM THỜI từ gallery/camera
  File? newAnhDaiDienFile;
  File? newAnhCCCDMatTruocFile;
  File? newAnhCCCDMatSauFile;
  File? newAnhBangCapFile;

  UserProfile({
    this.taiKhoanID,
    this.email,
    this.hoTen,
    this.soDienThoai,
    this.vaiTro,
    this.trangThai,
    this.diaChi,
    this.gioiTinh,
    this.ngaySinh,
    this.anhDaiDien,
    this.nguoiHocID,
    this.giaSuID,
    this.bangCap,
    this.kinhNghiem,
    this.anhCCCDMatTruoc,
    this.anhCCCDMatSau,
    this.anhBangCap,
    this.truongDaoTao,
    this.chuyenNganh,
    this.thanhTich,

    // ⭐️ THAY ĐỔI: Thêm vào constructor
    this.monID,
    this.tenMon,

    // ⭐️ THÊM vào constructor
    this.newAnhDaiDienFile,
    this.newAnhCCCDMatTruocFile,
    this.newAnhCCCDMatSauFile,
    this.newAnhBangCapFile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      taiKhoanID: json['TaiKhoanID'],
      email: json['Email'],
      hoTen: json['HoTen'],
      soDienThoai: json['SoDienThoai'],
      vaiTro: json['VaiTro'],
      trangThai: json['TrangThai'],
      diaChi: json['DiaChi'],
      gioiTinh: json['GioiTinh'],
      ngaySinh: json['NgaySinh'],
      anhDaiDien: json['AnhDaiDien'],
      nguoiHocID: json['NguoiHocID'],
      giaSuID: json['GiaSuID'],
      bangCap: json['BangCap'],
      kinhNghiem: json['KinhNghiem'],
      anhCCCDMatTruoc: json['AnhCCCD_MatTruoc'],
      anhCCCDMatSau: json['AnhCCCD_MatSau'],
      anhBangCap: json['AnhBangCap'],
      truongDaoTao: json['TruongDaoTao'],
      chuyenNganh: json['ChuyenNganh'],
      thanhTich: json['ThanhTich'],

      // ⭐️ THAY ĐỔI: Parse 1 môn học
      monID: json['MonID'],
      tenMon: json['TenMon'], // Sẽ có nếu bạn sửa AuthController.php
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'TaiKhoanID': taiKhoanID,
      'Email': email,
      'HoTen': hoTen,
      'SoDienThoai': soDienThoai,
      'VaiTro': vaiTro,
      'TrangThai': trangThai,
      'DiaChi': diaChi,
      'GioiTinh': gioiTinh,
      'NgaySinh': ngaySinh,
      'NguoiHocID': nguoiHocID,
      'GiaSuID': giaSuID,
      'BangCap': bangCap,
      'KinhNghiem': kinhNghiem,
      'TruongDaoTao': truongDaoTao,
      'ChuyenNganh': chuyenNganh,
      'ThanhTich': thanhTich,

      // ⭐️ THAY ĐỔI: Gửi đi 1 MonID
      'MonID': monID,
    };

    return data;
  }
}

class LoginResponse {
  final String token;
  final UserProfile user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['data'] ?? {};
    final token = json['token'] ?? '';

    return LoginResponse(token: token, user: UserProfile.fromJson(userData));
  }
}
