// file: lib/models/giao_dich_model.dart (HOÀN CHỈNH)

class GiaoDichModel {
  // === CÁC TRƯỜNG RESPONSE (Server trả về) ===
  final int? id; // (GiaoDichID)
  final String? trangThai;
  final String? maGiaoDich;
  final String? thoiGian; // (created_at)

  // === CÁC TRƯỜNG REQUEST (Client gửi đi) ===
  final int lopYeuCauID;
  final int taiKhoanID;
  final double soTien;
  final String loaiGiaoDich;
  final String? ghiChu;

  GiaoDichModel({
    this.id,
    this.trangThai,
    this.maGiaoDich,
    this.thoiGian,
    required this.lopYeuCauID,
    required this.taiKhoanID,
    required this.soTien,
    required this.loaiGiaoDich,
    this.ghiChu,
  });

  /// Hàm này để ApiService TỰ ĐỘNG PARSE JSON (khi nhận response)
  factory GiaoDichModel.fromJson(Map<String, dynamic> json) {
    return GiaoDichModel(
      // === SỬA ĐỔI: Sửa 'id' thành 'GiaoDichID' ===
      id: json['GiaoDichID'] ?? json['id'], // Ưu tiên 'GiaoDichID'
      // =========================================
      trangThai: json['TrangThai'],
      maGiaoDich: json['MaGiaoDich'],
      thoiGian: json['created_at'] ?? json['ThoiGian'],
      lopYeuCauID: json['LopYeuCauID'],
      taiKhoanID: json['TaiKhoanID'],
      soTien: double.tryParse(json['SoTien'].toString()) ?? 0.0,
      loaiGiaoDich: json['LoaiGiaoDich'],
      ghiChu: json['GhiChu'],
    );
  }

  /// Hàm này để ApiService GỬI DỮ LIỆU ĐI (khi tạo request)
  Map<String, dynamic> toJson() {
    return {
      'LopYeuCauID': lopYeuCauID,
      'TaiKhoanID': taiKhoanID,
      'SoTien': soTien,
      'LoaiGiaoDich': loaiGiaoDich,
      'GhiChu': ghiChu,
    };
  }
}