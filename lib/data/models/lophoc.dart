  class LopHoc {
    final int maLop;
    final String tieuDeLop;
    final String tenNguoiHoc;
    final String? diaChi; // vẫn giữ kiểu String
    final String hocPhi;
    final String? moTaChiTiet;
    final String? hinhThuc;
    final String? thoiLuong;
    final int? soLuong;
    final String? doiTuong;
    final String? thoiGianHoc;
    final String? trangThai;

    final int? monId;
    final int? khoiLopId;
    final String? ngayTao;
    final String? tenMon;
    final String? tenKhoiLop;
    final String? tenGiaSu;

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
      this.thoiGianHoc,
      this.trangThai,
      this.monId,
      this.khoiLopId,
      this.ngayTao,
      this.tenMon,
      this.tenKhoiLop,
      this.tenGiaSu,
    });

   factory LopHoc.fromJson(Map<String, dynamic> json) {
      return LopHoc(
        maLop: json['MaLop'] ?? json['LopYeuCauID'] ?? 0,
        tieuDeLop: json['TieuDeLop'] ?? json['TenMon'] ?? 'Không rõ môn học',
        tenNguoiHoc: json['TenNguoiHoc'] ?? 'Chưa rõ',
        diaChi: json['DiaChi']?.toString(),
        hocPhi: json['HocPhi']?.toString() ?? '0',
        moTaChiTiet: json['MoTaChiTiet']?.toString(),
        hinhThuc: json['HinhThuc']?.toString(),
        thoiLuong: json['ThoiLuong']?.toString(),
        soLuong: json['SoLuong'] is int ? json['SoLuong'] : int.tryParse(json['SoLuong']?.toString() ?? ''),
        doiTuong: json['DoiTuong']?.toString(),
        thoiGianHoc: json['ThoiGianHoc']?.toString(),
        trangThai: json['TrangThai'] ?? json['TrangThaiLop'] ?? '',
        monId: json['MonID'],
        khoiLopId: json['KhoiLopID'],
        ngayTao: json['NgayTao']?.toString(),
        tenMon: json['TenMon']?.toString(),
        tenKhoiLop: json['TenKhoiLop']?.toString(),
        tenGiaSu: json['TenGiaSu']?.toString(),
      );
    }
}
