// data/models/giasu.dart

// ignore_for_file: avoid_print

class Tutor {
  final int id;
  final String name;
  final String? diaChi;
  final String? gioiTinh;
  final String? ngaySinh;
  final String? bangCap;
  final String? kinhNghiem;
  final String image;
  final double rating;
  final String? email;
  final String? soDienThoai;
  final String? subject;

  Tutor({
    required this.id,
    required this.name,
    this.diaChi,
    this.gioiTinh,
    this.ngaySinh,
    this.bangCap,
    this.kinhNghiem,
    required this.image,
    required this.rating,
    this.email,
    this.soDienThoai,
    this.subject,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    final apiImage = json['AnhDaiDien'] as String?;
    final imageUrl = apiImage ?? 'https://i.pravatar.cc/300?img=${json['GiaSuID'] ?? 1}';
    final taiKhoanData = json['TaiKhoan'] as Map<String, dynamic>? ?? {};

    // ===> KIỂM TRA LỆNH PRINT NÀY CÓ TỒN TẠI KHÔNG <===
    print('>>> [Tutor.fromJson] GiaSuID: ${json['GiaSuID']}, AnhDaiDien: $apiImage, Final Image URL: $imageUrl');
    // ===================================================

    return Tutor(
      id: json['GiaSuID'] as int? ?? 0,
      name: json['HoTen'] as String? ?? 'Chưa có tên',
      diaChi: json['DiaChi'] as String?,
      gioiTinh: json['GioiTinh'] as String?,
      ngaySinh: json['NgaySinh'] as String?,
      bangCap: json['BangCap'] as String?,
      kinhNghiem: json['KinhNghiem'] as String?,
      image: imageUrl,
      rating: (json['DiemSo'] as num? ?? 0).toDouble(),
      email: taiKhoanData['Email'] as String?,
      soDienThoai: taiKhoanData['SoDienThoai'] as String?,
      subject: json['MonHoc'] as String? ?? 'Chuyên môn chưa cập nhật',
    );
  }

  String get displayGioiTinh {
    if (gioiTinh == null) return 'Chưa cập nhật';
    final lowerCaseGioiTinh = gioiTinh!.toLowerCase();
    if (lowerCaseGioiTinh == 'nam') return 'Nam';
    if (lowerCaseGioiTinh == 'nữ' || lowerCaseGioiTinh == 'nu') return 'Nữ';
    return gioiTinh!;
  }
}