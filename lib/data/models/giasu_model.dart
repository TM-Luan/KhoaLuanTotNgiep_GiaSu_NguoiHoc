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
  final int tongSoDanhGia;
  final TaiKhoan taiKhoan;
  final String? truongDaoTao;
  final String? chuyenNganh;
  final String? thanhTich;

  // [CẬP NHẬT] Thêm biến này
  final String? tenMon;

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
    this.tongSoDanhGia = 0,
    required this.taiKhoan,
    this.truongDaoTao,
    this.chuyenNganh,
    this.thanhTich,
    // [CẬP NHẬT] Thêm vào constructor
    this.tenMon,
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
      tongSoDanhGia: json['TongSoDanhGia'] ?? 0,
      taiKhoan: TaiKhoan.fromJson(json['TaiKhoan']),
      truongDaoTao: json['TruongDaoTao'],
      chuyenNganh: json['ChuyenNganh'],
      thanhTich: json['ThanhTich'],
      // [CẬP NHẬT] Map từ JSON
      tenMon: json['TenMon'],
    );
  }

  String get name => hoTen;
  // Getter này có thể trả về tenMon nếu muốn dùng chung
  String? get subject => tenMon ?? bangCap;
  double get rating => diemSo;
  String get image => anhDaiDien ?? '';
  int get reviewCount => tongSoDanhGia;
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
