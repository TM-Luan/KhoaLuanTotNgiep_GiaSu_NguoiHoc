import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_state.dart';
import '../../bloc/notification/notification_event.dart';
// Import các màn hình đích
import '../nguoihoc/student_class_proposals_screen.dart'; // Màn hình duyệt yêu cầu
import '../nguoihoc/class_detail_screen.dart'; // Màn hình chi tiết lớp (cho Gia sư)

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo'), centerTitle: true),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text("Bạn chưa có thông báo nào."));
            }
            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                return ListTile(
                  tileColor:
                      notif.isRead
                          ? Colors.white
                          : Colors.blue.withOpacity(0.1),
                  leading: Icon(
                    _getIconForType(notif.type),
                    color: notif.isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight:
                          notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                      ), // Nội dung đã có tên người + tên lớp từ Backend
                      const SizedBox(height: 4),
                      Text(
                        notif.createdAt,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // ... phần code phía trên giữ nguyên
                  onTap: () {
                    // 1. Đánh dấu đã đọc (giữ nguyên logic cũ)
                    if (!notif.isRead) {
                      context.read<NotificationBloc>().add(
                        MarkAsRead(notif.id),
                      );
                    }

                    // 2. XỬ LÝ ĐIỀU HƯỚNG (LOGIC MỚI)
                    if (notif.relatedId != null) {
                      // TRƯỜNG HỢP A: NGƯỜI HỌC bấm vào (Khi Gia sư xin dạy)
                      // -> Chuyển đến trang "Duyệt yêu cầu"
                      if (notif.type == 'request_received') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentClassProposalsScreen(
                                  lopHocId: notif.relatedId!,
                                ),
                          ),
                        );
                      }
                      // TRƯỜNG HỢP B: GIA SƯ bấm vào (Khi Người học mời dạy)
                      // -> Chuyển đến trang "Chi tiết lớp" (với quyền Tutor)
                      // Tại màn hình này, bạn sẽ hiển thị nút "Chấp nhận / Từ chối"
                      else if (notif.type == 'invitation_received') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ClassDetailScreen(
                                  classId: notif.relatedId!,
                                  userRole:
                                      UserRole
                                          .tutor, // Quan trọng: Để hiển thị nút thao tác của Gia sư
                                ),
                          ),
                        );
                      }
                      // TRƯỜNG HỢP C: Các thông báo kết quả (accepted/rejected/cancelled)
                      // -> Chuyển đến trang Chi tiết lớp để xem trạng thái mới
                      else {
                        // Xác định role dựa trên loại thông báo để UX tốt hơn (tuỳ chọn)
                        // Mặc định cứ chuyển vào trang chi tiết lớp
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ClassDetailScreen(
                                  classId: notif.relatedId!,
                                  // Nếu là thông báo 'request_accepted', nghĩa là mình là người gửi yêu cầu
                                  // Tuy nhiên ở đây để đơn giản ta có thể truyền role hiện tại của user nếu có lưu trong AuthBloc
                                  userRole:
                                      UserRole
                                          .tutor, // Hoặc UserRole.learner tuỳ ngữ cảnh
                                ),
                          ),
                        );
                      }
                    }
                  },

                  // ... phần code phía dưới giữ nguyên
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // Helper để chọn icon đẹp hơn
  IconData _getIconForType(String type) {
    switch (type) {
      case 'request_received':
        return Icons.person_add_alt_1; // Icon người đăng ký
      case 'request_accepted':
        return Icons.check_circle_outline; // Icon thành công
      case 'invitation_received':
        return Icons.mail_outline; // Icon lời mời
      default:
        return Icons.notifications;
    }
  }
}
