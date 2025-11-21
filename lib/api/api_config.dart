// api_config.dart - ĐÃ CẬP NHẬT
class ApiConfig {
  static const String baseUrl = 'https://tutorconectstudent.online/api';
  //static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Endpoints (Chung)
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String lopHocYeuCau = '/lophocyeucau';
  static const String changePassword = '/changepassword';
  static const String resetPassword = '/resetpassword';
  static const String routeName = '/tutor-detail';

  // Lịch học (Quản lý)
  static const String lichHocTheoLop =
      '/lop'; // GET /lop/{id}/lich-hoc-theo-thang
  static const String taoLichHocLapLai =
      '/lop'; // POST /lop/{id}/lich-hoc-lap-lai
  static const String capNhatLichHoc = '/lich-hoc'; // PUT /lich-hoc/{id}
  static const String xoaLichHoc = '/lich-hoc'; // DELETE /lich-hoc/{id}
  static const String taoGiaoDich = '/giao-dich';
  // === SỬA ĐỔI CHO GIẢI PHÁP 2 ===
  // Endpoints Lịch học Gia Sư
  static const String lichHocGiaSuSummary =
      '/giasu/lich-hoc-summary'; // GET (Tóm tắt tháng)
  static const String lichHocGiaSuTheoNgay =
      '/giasu/lich-hoc-theo-ngay'; // GET (Chi tiết ngày)

  // Endpoints Lịch học Người Học
  static const String lichHocNguoiHocSummary =
      '/nguoihoc/lich-hoc-summary'; // GET (Tóm tắt tháng)
  static const String lichHocNguoiHocTheoNgay =
      '/nguoihoc/lich-hoc-theo-ngay'; // GET (Chi tiết ngày)
  // === KẾT THÚC SỬA ĐỔI ===

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
