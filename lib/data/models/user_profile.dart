// FILE: user_profile.dart
// (Đã thêm trường nguoiHocID)

class UserProfile {
  bool? success;
  int? taiKhoanID;
  String? email;
  String? hoTen;
  String? soDienThoai;
  int? vaiTro; // Số nguyên (ví dụ: 1-Admin, 2-GiaSu, 3-NguoiHoc)
  int? trangThai;
  String? diaChi;
  String? gioiTinh;
  String? ngaySinh; // API trả về dạng String?
  String? bangCap;
  String? kinhNghiem;
  String? anhDaiDien;
  int? nguoiHocID;

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
    // Thêm vào constructor
    this.nguoiHocID,
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
      // === PARSE TRƯỜNG MỚI ===
      // API đã trả về NguoiHocID ngang hàng trong object 'data'
      nguoiHocID: data['NguoiHocID'],
    );
  }

  Map<String, dynamic> toJson() {
    // Hàm này dùng khi gửi UserProfile lên API (ví dụ: updateProfile)
    // Thêm nguoiHocID vào nếu cần thiết, nhưng thường không cần gửi ID này đi
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
      // 'NguoiHocID': nguoiHocID, // Thường không cần gửi ID này khi cập nhật
    };
  }
}

// Model LoginResponse không cần sửa
class LoginResponse {
  final String token;
  final UserProfile user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      // UserProfile.fromJson sẽ tự xử lý key 'data' bên trong nó
      user: UserProfile.fromJson(json),
    );
  }
}
