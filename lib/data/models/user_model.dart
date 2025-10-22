class User {
  final int taiKhoanID;
  final String email;
  final String soDienThoai;
  final int trangThai;
  final String ngayTao;
  final String token;

  User({
    required this.taiKhoanID,
    required this.email,
    required this.soDienThoai,
    required this.trangThai,
    required this.ngayTao,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final taiKhoan = json['TaiKhoan'];
    return User(
      taiKhoanID: taiKhoan['TaiKhoanID'],
      email: taiKhoan['Email'],
      soDienThoai: taiKhoan['SoDienThoai'],
      trangThai: taiKhoan['TrangThai'],
      ngayTao: taiKhoan['NgayTao'],
      token: json['token'],
    );
  }
}
