import 'user_profile.dart'; // thêm nếu chưa có

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
    // Kiểm tra nếu 'DiaChi' là object thì lấy trường con 'DiaChi' bên trong, ngược lại lấy luôn chuỗi
    String? parsedDiaChi; 
    if (json['DiaChi'] is Map<String, dynamic>) { 
      // Chỉ chạy nếu API trả về Map (lỗi cũ)
      parsedDiaChi = json['DiaChi']?['DiaChi']?.toString(); 
    } else {
      // === PHẦN XỬ LÝ CHÍNH ===
      // Nếu 'DiaChi' là String hoặc null, nó sẽ chạy vào đây
      // .toString() an toàn vì có dấu ? -> Nếu json['DiaChi'] là null, kết quả là null
      // Nếu json['DiaChi'] là String, kết quả là String đó
      parsedDiaChi = json['DiaChi']?.toString(); 
    }

    return LopHoc(
      maLop: json['MaLop'] as int,
      tieuDeLop: json['TieuDeLop'] as String,
      tenNguoiHoc: json['TenNguoiHoc'] as String,
      diaChi: parsedDiaChi, // dùng giá trị đã xử lý
      hocPhi: json['HocPhi'] as String,
      moTaChiTiet: json['MoTaChiTiet'] as String?,
      hinhThuc: json['HinhThuc'] as String?,
      thoiLuong: json['ThoiLuong']?.toString(),
      soLuong: json['SoLuong'] as int?,
      doiTuong: json['DoiTuong'] as String?,
      thoiGianHoc: json['ThoiGianHoc'] as String?,
      trangThai: json['TrangThai'] as String?,
      monId: json['MonID'] as int?,
      khoiLopId: json['KhoiLopID'] as int?,
      ngayTao: json['NgayTao'] as String?,
      tenMon: json['TenMon'] as String?,
      tenKhoiLop: json['TenKhoiLop'] as String?,
      tenGiaSu: json['TenGiaSu'] as String?,
    );
  }
}