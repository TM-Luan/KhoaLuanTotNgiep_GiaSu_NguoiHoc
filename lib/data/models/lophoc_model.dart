class LopHoc {
  final int maLop;
  final String tieuDeLop;
  final String tenNguoiHoc;
  final String? soDienThoai;
  final String? diaChi;
  final String hocPhi; // Giữ String để hiển thị, xử lý tính toán sẽ parse sau
  final String? moTaChiTiet;
  final String? hinhThuc;
  final int? thoiLuong;
  final int? soLuong;
  final String? doiTuong;
  final String? trangThai;
  final int? soBuoiTuan;
  final String? lichHocMongMuon;
  final int? monId;
  final int? khoiLopId;
  final String? ngayTao;
  final String? tenMon;
  final String? tenKhoiLop;
  final String? tenGiaSu;
  final int? doiTuongID;
  final String? trangThaiThanhToan;
  final int? nguoiHocId;

  LopHoc({
    required this.maLop,
    required this.tieuDeLop,
    required this.tenNguoiHoc,
    this.soDienThoai,
    this.diaChi,
    required this.hocPhi,
    this.moTaChiTiet,
    this.hinhThuc,
    this.thoiLuong,
    this.soLuong,
    this.doiTuong,
    this.trangThai,
    this.soBuoiTuan,
    this.lichHocMongMuon,
    this.monId,
    this.khoiLopId,
    this.ngayTao,
    this.tenMon,
    this.tenKhoiLop,
    this.tenGiaSu,
    this.doiTuongID,
    this.trangThaiThanhToan,
    this.nguoiHocId,
  });

  factory LopHoc.fromJson(Map<String, dynamic> json) {
    // Helper: Parse an toàn sang int
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      if (val is double) return val.toInt();
      return null;
    }

    // Helper: Parse an toàn sang String (đặc biệt cho HocPhi)
    String parseString(dynamic val, String defaultVal) {
      if (val == null) return defaultVal;
      return val.toString();
    }

    return LopHoc(
      maLop: parseInt(json['MaLop']) ?? parseInt(json['LopYeuCauID']) ?? 0,
      tieuDeLop: json['TieuDeLop'] ?? json['TenMon'] ?? 'Lớp học',
      tenNguoiHoc: json['TenNguoiHoc'] ?? 'Chưa cập nhật',
      soDienThoai: json['SoDienThoai']?.toString(),
      diaChi: json['DiaChi']?.toString(),
      // Parse HocPhi an toàn dù API trả về số hay chuỗi
      hocPhi: parseString(json['HocPhi'], '0'),
      moTaChiTiet: json['MoTaChiTiet']?.toString(),
      hinhThuc: json['HinhThuc']?.toString(),
      thoiLuong: parseInt(json['ThoiLuong']),
      soLuong: parseInt(json['SoLuong']),
      doiTuong: json['DoiTuong']?.toString(),
      trangThai: json['TrangThai'] ?? json['TrangThaiLop'] ?? '',
      soBuoiTuan: parseInt(json['SoBuoiTuan']),
      lichHocMongMuon: json['LichHocMongMuon']?.toString(),
      monId: parseInt(json['MonID']),
      khoiLopId: parseInt(json['KhoiLopID']),
      doiTuongID: parseInt(json['DoiTuongID']),
      ngayTao: json['NgayTao']?.toString(),
      tenMon: json['TenMon']?.toString(),
      tenKhoiLop: json['TenKhoiLop']?.toString(),
      tenGiaSu: json['TenGiaSu']?.toString(),
      trangThaiThanhToan: json['TrangThaiThanhToan']?.toString(),
      nguoiHocId: parseInt(json['NguoiHocID']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaLop': maLop,
      'TieuDeLop': tieuDeLop,
      'NguoiHocID': nguoiHocId,
      'SoDienThoai': soDienThoai,
      'DiaChi': diaChi,
      'HocPhi': hocPhi,
      'MoTaChiTiet': moTaChiTiet,
      'HinhThuc': hinhThuc,
      'ThoiLuong': thoiLuong,
      'SoLuong': soLuong,
      'DoiTuong': doiTuong,
      'TrangThai': trangThai,
      'SoBuoiTuan': soBuoiTuan,
      'LichHocMongMuon': lichHocMongMuon,
      'MonID': monId,
      'KhoiLopID': khoiLopId,
    };
  }
}