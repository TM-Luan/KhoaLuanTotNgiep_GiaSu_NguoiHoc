class LopHoc {
  final String maLop;
  final String tenLop;
  final String tenHocVien;
  final String diaChi;
  final int hocPhi;
  final int phiNhanLop;

  LopHoc({
    required this.maLop,
    required this.tenLop,
    required this.tenHocVien,
    required this.diaChi,
    required this.hocPhi,
    required this.phiNhanLop,
  });
}

// ============= DỮ LIỆU GIẢ LẬP =============
final dsLopHoc = [
  LopHoc(
    maLop: "0001",
    tenLop: "Anh văn 12 + Toán",
    tenHocVien: "Trần Minh Luân",
    diaChi: "Ấp 5, Tân Tây, Gò Công Đông, Tiền Giang",
    hocPhi: 180000,
    phiNhanLop: 650000,
  ),
  LopHoc(
    maLop: "0002",
    tenLop: "Toán 9 + Lý 9",
    tenHocVien: "Nguyễn Hồng Anh",
    diaChi: "Ấp 3, Phước Lâm, Cần Giuộc, Long An",
    hocPhi: 150000,
    phiNhanLop: 500000,
  ),
  LopHoc(
    maLop: "0003",
    tenLop: "Hóa 11 + Sinh 11",
    tenHocVien: "Lê Hữu Đạt",
    diaChi: "Phú Mỹ, Tân Thành, Bà Rịa - Vũng Tàu",
    hocPhi: 200000,
    phiNhanLop: 700000,
  ),
  LopHoc(
    maLop: "0004",
    tenLop: "Toán 12 + Lý 12",
    tenHocVien: "Phạm Thùy Dương",
    diaChi: "Phước Vĩnh An, Củ Chi, TP.HCM",
    hocPhi: 220000,
    phiNhanLop: 800000,
  ),
  LopHoc(
    maLop: "0005",
    tenLop: "Toán 6 + Tiếng Anh 6",
    tenHocVien: "Ngô Văn Minh",
    diaChi: "Bình Chánh, TP.HCM",
    hocPhi: 130000,
    phiNhanLop: 400000,
  ),
];
