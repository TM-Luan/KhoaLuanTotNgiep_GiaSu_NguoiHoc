// user_profile.dart

class UserProfile {
  bool? success;
  int? taiKhoanID;
  String? email;
  String? hoTen;
  String? soDienThoai;
  int? vaiTro; // 1: Admin, 2: GiaSu, 3: NguoiHoc
  int? trangThai;
  String? diaChi;
  String? gioiTinh;
  String? ngaySinh;
  String? bangCap;
  String? kinhNghiem;
  String? anhDaiDien;

  int? nguoiHocID;
  int? giaSuID;

  UserProfile({
    this.success,
    this.taiKhoanID,
    this.email,
    this.hoTen,
    this.soDienThoai,
    this.vaiTro,
    this.trangThai,
    this.diaChi,
    this.gioiTinh,
    this.ngaySinh,
    this.bangCap,
    this.kinhNghiem,
    this.anhDaiDien,
    this.nguoiHocID,
    this.giaSuID,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return UserProfile(
      success: json['success'],
      taiKhoanID: data['TaiKhoanID'],
      email: data['Email'],
      hoTen: data['HoTen'],
      soDienThoai: data['SoDienThoai'],
      vaiTro: data['VaiTro'],
      trangThai: data['TrangThai'],
      diaChi: data['DiaChi'],
      gioiTinh: data['GioiTinh'],
      ngaySinh: data['NgaySinh'],
      bangCap: data['BangCap'],
      kinhNghiem: data['KinhNghiem'],
      anhDaiDien: data['AnhDaiDien'],
      nguoiHocID: data['NguoiHocID'],
      giaSuID: data['GiaSuID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TaiKhoanID': taiKhoanID,
      'Email': email,
      'HoTen': hoTen,
      'SoDienThoai': soDienThoai,
      'VaiTro': vaiTro,
      'TrangThai': trangThai,
      'DiaChi': diaChi,
      'GioiTinh': gioiTinh,
      'NgaySinh': ngaySinh,
      'BangCap': bangCap,
      'KinhNghiem': kinhNghiem,
      'AnhDaiDien': anhDaiDien,
      'NguoiHocID': nguoiHocID,
      'GiaSuID': giaSuID,
    };
  }
}

// ✅ LoginResponse chuẩn
class LoginResponse {
  final String token;
  final UserProfile user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    
    // Token ở cấp độ gốc, data ở trong object "data"
    final userData = json['data'] ?? {}; 
    final token = json['token'] ?? '';

    return LoginResponse(
      token: token,
      user: UserProfile.fromJson({'data': userData}), // Wrap userData trong data để UserProfile.fromJson parse đúng
    );
  }
}
