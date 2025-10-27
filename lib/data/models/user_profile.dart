class UserProfile {
  bool? success;
  int? taiKhoanID;
  String? email;
  String? hoTen;
  String? soDienThoai;
  int? vaiTro;
  int? trangThai;
  String? diaChi;
  String? gioiTinh;
  String? ngaySinh;
  String? bangCap;
  String? kinhNghiem;
  String? anhDaiDien;

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
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json; // xử lý trường hợp có hoặc không có 'data'
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
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
    };
  }
}
class LoginResponse {
  final String token;
  final UserProfile user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '', // Xử lý null
      user: UserProfile.fromJson(json['data'] ?? {}), // Xử lý null
    );
  }
}