import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_state.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../nguoihoc/student_class_proposals_screen.dart';
import '../nguoihoc/class_detail_screen.dart';
import '../giasu/tutor_my_classes_screen.dart';
import '../nguoihoc/student_my_classes_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                return _buildNotificationItem(context, notif);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, dynamic notif) {
    final backgroundColor =
        notif.isRead ? Colors.white : const Color(0xFFF0F9FF);
    final titleColor = notif.isRead ? Colors.black87 : Colors.black;
    final messageColor = notif.isRead ? Colors.grey.shade600 : Colors.black87;
    final fontWeight = notif.isRead ? FontWeight.normal : FontWeight.w600;

    return InkWell(
      onTap: () {
        // 1. Đánh dấu đã đọc
        if (!notif.isRead) {
          context.read<NotificationBloc>().add(MarkAsRead(notif.id));
        }

        // 2. XỬ LÝ ĐIỀU HƯỚNG (NAVIGATION)
        if (notif.relatedId != null) {
          final authState = context.read<AuthBloc>().state;
          final isGiaSu =
              (authState is AuthAuthenticated && authState.user.vaiTro == 2);

          // === TRƯỜNG HỢP 1: "Yêu cầu dạy mới" (Hình ảnh 1) ===
          // Người học nhận được thông báo có Gia sư đăng ký
          if (notif.type == 'request_received') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        StudentClassProposalsScreen(lopHocId: notif.relatedId!),
              ),
            );
          }
          // === TRƯỜNG HỢP 2: "Yêu cầu bị từ chối" (Hình ảnh 2) ===
          // Gia sư từ chối lời mời -> Người học vào xem lại chi tiết lớp
          else if (notif.type == 'request_rejected') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ClassDetailScreen(
                      classId: notif.relatedId!,
                      userRole: isGiaSu ? UserRole.tutor : UserRole.student,
                    ),
              ),
            );
          }
          // === CÁC TRƯỜNG HỢP KHÁC (Giữ nguyên logic cũ) ===
          else if (notif.type == 'invitation_received') {
            // Gia sư nhận lời mời từ học viên -> Vào tab "Lời mời"
            if (isGiaSu) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const TutorMyClassesScreen(initialTabIndex: 2),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ClassDetailScreen(
                        classId: notif.relatedId!,
                        userRole: UserRole.tutor,
                      ),
                ),
              );
            }
          } else if (notif.type == 'request_accepted') {
            // Chấp nhận -> Vào tab "Đang dạy/Đang học" (Index 0)
            if (isGiaSu) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const TutorMyClassesScreen(initialTabIndex: 0),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const StudentMyClassesPage(initialTabIndex: 0),
                ),
              );
            }
          } else {
            // Mặc định: Vào trang chi tiết lớp
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ClassDetailScreen(
                      classId: notif.relatedId!,
                      userRole: isGiaSu ? UserRole.tutor : UserRole.student,
                    ),
              ),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    notif.isRead ? Colors.grey.shade100 : Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notif.type),
                color: notif.isRead ? Colors.grey : Colors.blue.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: fontWeight,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notif.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              notif.isRead
                                  ? Colors.grey.shade400
                                  : Colors.blue.shade400,
                          fontWeight:
                              notif.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: messageColor,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 18),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "Bạn chưa có thông báo nào",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Cập nhật icon phù hợp với hình ảnh của bạn
  IconData _getIconForType(String type) {
    switch (type) {
      case 'request_received':
        return Icons.person_add_rounded; // Icon người cộng (Hình 1)
      case 'request_accepted':
        return Icons.check_circle_rounded;
      case 'invitation_received':
        return Icons.mark_email_unread_rounded;
      case 'request_rejected':
        return Icons.cancel_rounded; // Icon dấu x (Hình 2)
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(String createdAt) {
    try {
      if (createdAt.length > 10) {
        return createdAt.substring(0, 10);
      }
      return createdAt;
    } catch (e) {
      return "";
    }
  }
}
