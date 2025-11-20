import '../../data/models/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  // Đếm số lượng chưa đọc để hiện chấm đỏ trên chuông
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
