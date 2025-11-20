class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type; // 'request_received', 'request_accepted', ...
  final int? relatedId; // ID lớp hoặc ID yêu cầu
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      relatedId: json['related_id'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'],
    );
  }
}