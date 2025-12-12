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

// 1. Đổi từ StatelessWidget sang StatefulWidget
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // 2. Thêm initState để tự động tải dữ liệu khi màn hình mở ra
  @override
  void initState() {
    super.initState();
    // Gọi lệnh tải thông báo ngay khi màn hình được tạo
    context.read<NotificationBloc>().add(LoadNotifications());
  }

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
        // Thêm nút refresh thủ công nếu muốn
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotificationBloc>().add(LoadNotifications());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            // Bọc trong RefreshIndicator để cho phép kéo xuống để tải lại
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(LoadNotifications());
              },
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  return _buildNotificationItem(context, notif);
                },
              ),
            );
          } else if (state is NotificationError) {
            // Hiển thị lỗi và nút thử lại
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  // ... (Giữ nguyên các hàm _buildNotificationItem, _buildEmptyState, _getIconForType, _formatTime cũ của bạn) ...

  Widget _buildNotificationItem(BuildContext context, dynamic notif) {
    // Copy y nguyên nội dung hàm này từ code cũ của bạn
    final backgroundColor =
        notif.isRead ? Colors.white : const Color(0xFFF0F9FF);
    final titleColor = notif.isRead ? Colors.black87 : Colors.black;
    final messageColor = notif.isRead ? Colors.grey.shade600 : Colors.black87;
    final fontWeight = notif.isRead ? FontWeight.normal : FontWeight.w600;

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          context.read<NotificationBloc>().add(MarkAsRead(notif.id));
        }

        if (notif.relatedId != null) {
          final authState = context.read<AuthBloc>().state;
          final isGiaSu =
              (authState is AuthAuthenticated && authState.user.vaiTro == 2);

          if (notif.type == 'request_received') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        StudentClassProposalsScreen(lopHocId: notif.relatedId!),
              ),
            );
          } else if (notif.type == 'request_rejected') {
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
          } else if (notif.type == 'invitation_received') {
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'request_received':
        return Icons.person_add_rounded;
      case 'request_accepted':
        return Icons.check_circle_rounded;
      case 'invitation_received':
        return Icons.mark_email_unread_rounded;
      case 'request_rejected':
        return Icons.cancel_rounded;
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
