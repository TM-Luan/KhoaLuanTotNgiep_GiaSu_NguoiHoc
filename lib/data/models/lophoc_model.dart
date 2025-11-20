// file: lib/data/models/lophoc_model.dart

class LopHoc {
  final int maLop;
  final String tieuDeLop;
  final String tenNguoiHoc;
  final String? soDienThoai;
  final String? diaChi;
  final String hocPhi;
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
  // NEW: Thêm trường trạng thái thanh toán
  final String? trangThaiThanhToan;

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
  });

  factory LopHoc.fromJson(Map<String, dynamic> json) {
    return LopHoc(
      maLop: json['MaLop'] ?? json['LopYeuCauID'] ?? 0,
      tieuDeLop: json['TieuDeLop'] ?? json['TenMon'] ?? 'Không rõ môn học',
      tenNguoiHoc: json['TenNguoiHoc'] ?? 'Chưa rõ',
      soDienThoai: json['SoDienThoai']?.toString(),
      diaChi: json['DiaChi']?.toString(),
      hocPhi: json['HocPhi']?.toString() ?? '0',
      moTaChiTiet: json['MoTaChiTiet']?.toString(),
      hinhThuc: json['HinhThuc']?.toString(),
      thoiLuong: json['ThoiLuong'] is int
              ? json['ThoiLuong']
              : int.tryParse(json['ThoiLuong']?.toString() ?? ''),
      soLuong: json['SoLuong'] is int
              ? json['SoLuong']
              : int.tryParse(json['SoLuong']?.toString() ?? ''),
      doiTuong: json['DoiTuong']?.toString(),
      trangThai: json['TrangThai'] ?? json['TrangThaiLop'] ?? '',
      soBuoiTuan: json['SoBuoiTuan'] is int
              ? json['SoBuoiTuan']
              : int.tryParse(json['SoBuoiTuan']?.toString() ?? ''),
      lichHocMongMuon: json['LichHocMongMuon']?.toString(),
      monId: json['MonID'],
      khoiLopId: json['KhoiLopID'],
      doiTuongID: json['DoiTuongID'],
      ngayTao: json['NgayTao']?.toString(),
      tenMon: json['TenMon']?.toString(),
      tenKhoiLop: json['TenKhoiLop']?.toString(),
      tenGiaSu: json['TenGiaSu']?.toString(),
      // NEW: Map dữ liệu từ JSON (Giả sử API trả về trường này)
      trangThaiThanhToan: json['TrangThaiThanhToan']?.toString(),
    );
  }
}