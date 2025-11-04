// api_config.dart - SỬA LẠI ENDPOINTS
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

  // === ENDPOINTS SỬA LẠI CHO LỊCH HỌC ===
  static const String lichHocTheoLop = '/lop-hoc'; // GET /lop-hoc/{id}/lich-hoc
  static const String taoLichHocGiaSu = '/giasu/lop-hoc'; // POST /giasu/lop-hoc/{id}/lich-hoc
  static const String capNhatLichHoc = '/giasu/lich-hoc'; // PUT /giasu/lich-hoc/{id}
  
  // Endpoints mới dựa trên API backend thực tế
  static const String lichHocCuaGiaSu = '/giasu/lich-hoc'; // GET cho gia sư
  static const String lichHocCuaNguoiHoc = '/nguoihoc/lich-hoc'; // GET cho người học

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}