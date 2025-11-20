abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class MarkAsRead extends NotificationEvent {
  final int id;
  MarkAsRead(this.id);
}