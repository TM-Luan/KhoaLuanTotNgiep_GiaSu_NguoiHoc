class LopHoc {
  final int maLop;
  final String tieuDeLop;
  final String tenNguoiHoc;
  final String? diaChi;
  final String hocPhi;
  final String? moTaChiTiet;
  final String? hinhThuc;
  final int? thoiLuong;
  final int? soLuong;
  final String? doiTuong;
  final String? trangThai;

  // SỬA: Thêm 2 trường này
  final int? soBuoiTuan;
  final String? lichHocMongMuon;

  // SỬA: Xóa 2 trường cũ
  // final String? thoiGianHoc;
  // final int? thoiGianDayID;

  final int? monId;
  final int? khoiLopId;
  final String? ngayTao;
  final String? tenMon;
  final String? tenKhoiLop;
  final String? tenGiaSu;
  final int? doiTuongID;

  LopHoc({
    required this.maLop,
    required this.tieuDeLop,
    required this.tenNguoiHoc,
    this.diaChi,
    required this.hocPhi,
    this.moTaChiTiet,
    this.hinhThuc,
    this.thoiLuong,
    this.soLuong,
    this.doiTuong,
    this.trangThai,

    // SỬA: Thêm vào constructor
    this.soBuoiTuan,
    this.lichHocMongMuon,

    // SỬA: Xóa khỏi constructor
    // this.thoiGianHoc,
    // this.thoiGianDayID,
    this.monId,
    this.khoiLopId,
    this.ngayTao,
    this.tenMon,
    this.tenKhoiLop,
    this.tenGiaSu,
    this.doiTuongID,
  });

  factory LopHoc.fromJson(Map<String, dynamic> json) {
    return LopHoc(
      maLop: json['MaLop'] ?? json['LopYeuCauID'] ?? 0,
      tieuDeLop: json['TieuDeLop'] ?? json['TenMon'] ?? 'Không rõ môn học',
      tenNguoiHoc: json['TenNguoiHoc'] ?? 'Chưa rõ',
      diaChi: json['DiaChi']?.toString(),
      hocPhi: json['HocPhi']?.toString() ?? '0',
      moTaChiTiet: json['MoTaChiTiet']?.toString(), // Key này khớp với Resource
      hinhThuc: json['HinhThuc']?.toString(),
      thoiLuong:
          json['ThoiLuong'] is int
              ? json['ThoiLuong']
              : int.tryParse(json['ThoiLuong']?.toString() ?? ''),
      soLuong:
          json['SoLuong'] is int
              ? json['SoLuong']
              : int.tryParse(json['SoLuong']?.toString() ?? ''),
      doiTuong: json['DoiTuong']?.toString(),
      trangThai: json['TrangThai'] ?? json['TrangThaiLop'] ?? '',

      // SỬA: Cập nhật fromJson
      soBuoiTuan:
          json['SoBuoiTuan'] is int
              ? json['SoBuoiTuan']
              : int.tryParse(json['SoBuoiTuan']?.toString() ?? ''),
      lichHocMongMuon: json['LichHocMongMuon']?.toString(),

      // SỬA: Xóa 2 dòng
      // thoiGianHoc: json['ThoiGianHoc']?.toString(),
      // thoiGianDayID: json['ThoiGianDayID'],
      monId: json['MonID'],
      khoiLopId: json['KhoiLopID'],
      doiTuongID: json['DoiTuongID'],
      ngayTao: json['NgayTao']?.toString(),
      tenMon: json['TenMon']?.toString(),
      tenKhoiLop: json['TenKhoiLop']?.toString(),
      tenGiaSu: json['TenGiaSu']?.toString(),
    );
  }
}
