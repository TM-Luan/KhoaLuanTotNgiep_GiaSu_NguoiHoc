
import '../models/notification_model.dart';
import '../../api/api_service.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get('/notifications');

      // SỬA LỖI Ở ĐÂY:
      // ApiService đã bóc 'data' rồi, nên response.data chính là List
      // Ta kiểm tra response.success và response.data khác null là được
      if (response.success && response.data != null) {
        // Ép kiểu trực tiếp response.data thành List
        return (response.data as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      // Thêm dòng in lỗi này để nếu có lỗi khác bạn sẽ thấy trong Debug Console
      throw Exception('Lỗi lấy thông báo: $e');
    }
  }

  // ... hàm markAsRead giữ nguyên ...
  Future<void> markAsRead(int id) async {
    try {
      await _apiService.put('/notifications/$id/read', data: {});
    } catch (e) {
      throw Exception('Lỗi đánh dấu thông báo đã đọc: $e');
    }
  }
}
