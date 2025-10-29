import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _nguoiHocIdKey = 'nguoiHocId'; // Đảm bảo key này đúng


  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // 🔧 Thêm phương thức này
  static Future<void> clearToken() async {
    await _storage.deleteAll();
  }

  // Trong flutter_secure_storage.dart
static Future<void> deleteNguoiHocID() async {
  try {
    await _storage.delete(key: _nguoiHocIdKey);
  } catch (e) {
    print("Lỗi khi xóa NguoiHocID khỏi SecureStorage: $e");
  }
}

  

  // ... (các hàm getToken, saveToken...)

  // === HÀM BẠN CẦN THÊM ===
  static Future<String?> getNguoiHocID() async {
    try {
      return await _storage.read(key: _nguoiHocIdKey);
    } catch (e) {
      print("Lỗi khi đọc NguoiHocID từ SecureStorage: $e");
      return null;
    }
  }

  // Bạn cũng cần hàm lưu ID sau khi đăng nhập thành công
  static Future<void> saveNguoiHocID(String id) async {
     try {
       await _storage.write(key: _nguoiHocIdKey, value: id);
     } catch (e) {
       print("Lỗi khi lưu NguoiHocID vào SecureStorage: $e");
     }
  }
}
