// api_config.dart - THÊM ENDPOINTS MỚI
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String lopHocYeuCau = '/lophocyeucau';
  static const String changePassword = '/changepassword';
  static const String resetPassword = '/resetpassword';
  static const String routeName = '/tutor-detail';

  // Lịch học endpoints
  static const String lichHocTheoLop = '/lop'; // GET /lop/{id}/lich-hoc
  static const String taoLichHocLapLai = '/lop'; // POST /lop/{id}/lich-hoc-lap-lai
  static const String taoLichHocDon = '/lop'; // POST /lop/{id}/lich-hoc
  static const String capNhatLichHoc = '/lich-hoc'; // PUT /lich-hoc/{id}
  static const String xoaLichHoc = '/lich-hoc'; // DELETE /lich-hoc/{id}
  
  // THÊM MỚI: Endpoints cho lịch học theo người học và gia sư
  static const String lichHocNguoiHoc = '/nguoihoc/lich-hoc'; // GET
  static const String lichHocGiaSu = '/giasu/lich-hoc'; // GET

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}