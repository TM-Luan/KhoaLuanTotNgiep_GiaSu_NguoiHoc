class Tutor {
  final int giaSuID;
  final String hoTen;
  final String? diaChi;
  final String? gioiTinh;
  final String? ngaySinh;
  final String? bangCap;
  final String? kinhNghiem;
  final String? anhDaiDien;
  final double diemSo;
  final TaiKhoan taiKhoan;

  String? soDienThoai;

  Tutor({
    required this.giaSuID,
    required this.hoTen,
    this.diaChi,
    this.gioiTinh,
    this.ngaySinh,
    this.bangCap,
    this.kinhNghiem,
    this.anhDaiDien,
    required this.diemSo,
    required this.taiKhoan,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      giaSuID: json['GiaSuID'],
      hoTen: json['HoTen'],
      diaChi: json['DiaChi'],
      gioiTinh: json['GioiTinh'],
      ngaySinh: json['NgaySinh'],
      bangCap: json['BangCap'],
      kinhNghiem: json['KinhNghiem'],
      anhDaiDien: json['AnhDaiDien'],
      diemSo: (json['DiemSo'] as num?)?.toDouble() ?? 0.0,
      taiKhoan: TaiKhoan.fromJson(json['TaiKhoan']),
    );
  }

  // Getter để tương thích với TutorCard hiện tại
  String get name => hoTen;
  String? get subject => bangCap;
  double get rating => diemSo;
  String get image => anhDaiDien ?? '';
}

class TaiKhoan {
  final int taiKhoanID;
  final String email;
  final String soDienThoai;

  TaiKhoan({
    required this.taiKhoanID,
    required this.email,
    required this.soDienThoai,
  });

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      taiKhoanID: json['TaiKhoanID'],
      email: json['Email'],
      soDienThoai: json['SoDienThoai'],
    );
  }
}
