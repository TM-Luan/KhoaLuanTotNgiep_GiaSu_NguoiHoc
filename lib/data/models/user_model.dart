class UserModel {
  final int taiKhoanID;
  final String email;
  final String hoTen;
  final String soDienThoai;
  final int vaiTro;

  UserModel({
    required this.taiKhoanID,
    required this.email,
    required this.hoTen,
    required this.soDienThoai,
    required this.vaiTro,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      taiKhoanID: json['TaiKhoanID'] ?? 0,
      email: json['Email'] ?? '',
      hoTen: json['HoTen'] ?? '',
      soDienThoai: json['SoDienThoai'] ?? '',
      vaiTro: json['VaiTro'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TaiKhoanID': taiKhoanID,
      'Email': email,
      'HoTen': hoTen,
      'SoDienThoai': soDienThoai,
      'VaiTro': vaiTro,
    };
  }
}

class LoginResponse {
  final String token;
  final UserModel user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '', // Xử lý null
      user: UserModel.fromJson(json['data'] ?? {}), // Xử lý null
    );
  }
}
