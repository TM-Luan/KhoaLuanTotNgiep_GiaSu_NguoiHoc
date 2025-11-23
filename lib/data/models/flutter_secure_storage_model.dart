import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _nguoiHocIdKey = 'nguoiHocId';

  // 1. Thêm các key mới cho chức năng Ghi nhớ
  static const _emailKey = 'saved_email';
  static const _passKey = 'saved_pass';
  static const _rememberKey = 'is_remember';

  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.deleteAll();
  }

  static Future<void> deleteNguoiHocID() async {
    await _storage.delete(key: _nguoiHocIdKey);
  }

  static Future<String?> getNguoiHocID() async {
    try {
      return await _storage.read(key: _nguoiHocIdKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveNguoiHocID(String id) async {
    await _storage.write(key: _nguoiHocIdKey, value: id);
  }

  // 2. Hàm lưu thông tin đăng nhập (Dùng cho nút Ghi nhớ)
  static Future<void> saveLoginInfo(
    String email,
    String password,
    bool isRemember,
  ) async {
    if (isRemember) {
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _passKey, value: password);
      await _storage.write(key: _rememberKey, value: 'true');
    } else {
      // Nếu không chọn ghi nhớ thì xóa thông tin cũ đi
      await clearLoginInfo();
    }
  }

  // 3. Hàm lấy thông tin đã lưu
  static Future<Map<String, dynamic>> getLoginInfo() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passKey);
    final isRemember = await _storage.read(key: _rememberKey);

    return {
      'email': email ?? '',
      'password': password ?? '',
      'isRemember': isRemember == 'true',
    };
  }

  // 4. Hàm xóa thông tin đăng nhập
  static Future<void> clearLoginInfo() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passKey);
    await _storage.delete(key: _rememberKey);
  }
}
