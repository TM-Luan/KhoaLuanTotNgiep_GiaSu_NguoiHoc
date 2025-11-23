class ComplaintModel {
  final int id;
  final String noiDung;
  final String trangThai; 
  final String ngayTao;
  final int? lopId; // <--- THÊM DÒNG NÀY

  ComplaintModel({
    required this.id,
    required this.noiDung,
    required this.trangThai,
    required this.ngayTao,
    this.lopId, // <--- THÊM DÒNG NÀY
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      // SỬA: Lấy đúng key 'KhieuNaiID' từ Server
      id: json['KhieuNaiID'] ?? json['id'] ?? 0,
      
      noiDung: json['NoiDung'] ?? '',
      trangThai: json['TrangThai'] ?? 'TiepNhan',
      
      // SỬA: Lấy đúng key 'NgayTao' thay vì 'created_at'
      ngayTao: json['NgayTao'] ?? json['created_at'] ?? DateTime.now().toString(), 
      lopId: json['LopYeuCauID'], // <--- QUAN TRỌNG
    );
  }
}