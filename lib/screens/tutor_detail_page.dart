// screens/tutor_detail_page.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
// ===> SỬA LỖI IMPORT: Dùng dấu : thay vì . <===
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:url_launcher/url_launcher.dart';
// Optional: import 'package:intl/intl.dart'; // Để format ngày sinh

class TutorDetailPage extends StatelessWidget {
  static const routeName = '/tutor-detail';

  const TutorDetailPage({super.key});

  // ===> XÓA CÁC KHAI BÁO HÀM TRÙNG LẶP Ở ĐÂY <===
  // Widget _buildInfoRow(...) // Đã xóa
  // Widget _buildActionButton(...) // Đã xóa
  // Future<void> _makePhoneCall(...) // Đã xóa
  // Future<void> _sendEmail(...) // Đã xóa
  // Optional: // String _formatDate(...) // Đã xóa (Nếu bạn đã thêm)

  @override
  Widget build(BuildContext context) {
    // --- Phần lấy arguments ---
    print('>>> [TutorDetailPage] Build method started.');
    print('>>> [TutorDetailPage] Attempting to get arguments...');
    Object? args = ModalRoute.of(context)?.settings.arguments;
    print('>>> [TutorDetailPage] Received arguments raw object: $args');
    print(
      '>>> [TutorDetailPage] Received arguments raw type: ${args?.runtimeType}',
    );

    Tutor? tutor;
    // ===> KIỂM TRA TYPE AN TOÀN HƠN <===
    if (args is Tutor) {
      tutor = args;
      print(
        '>>> [TutorDetailPage] Successfully cast arguments to Tutor: ${tutor.name}',
      );
    } else {
      print(
        '>>> [TutorDetailPage] FAILED to cast arguments to Tutor or arguments are null/wrong type.',
      );
    }

    if (tutor == null) {
      print('>>> [TutorDetailPage] Tutor object is null. Building error view.');
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không có dữ liệu gia sư.')),
      );
    }

    print(
      '>>> [TutorDetailPage] Tutor object received successfully. Building detail view for ${tutor.name}...',
    );

    // --- Xác định avatarWidget ---
    final bool isPlaceholderImage =
        tutor.image.contains('pravatar.cc') ||
        tutor.image.isEmpty; // Thêm kiểm tra rỗng
    Widget avatarWidget;
    if (isPlaceholderImage) {
      avatarWidget = CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.primaryBlue.withAlpha((255 * 0.1).round()),
        child: Icon(
          Icons.person_outline, // Dùng icon outline
          size: 50,
          color: AppColors.primaryBlue.withAlpha((255 * 0.7).round()),
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(tutor.image),
        onBackgroundImageError: (_, __) {
          print('>>> Error loading tutor image: ${tutor?.image}');
        },
        backgroundColor: AppColors.lightGrey,
      );
    }

    // --- Phần UI chính ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Gia Sư'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  avatarWidget,
                  const SizedBox(height: 12),
                  Text(
                    tutor.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${tutor.rating.toStringAsFixed(1)}/5.0',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Liên hệ & Hành động
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.phone_outlined,
                    'Số điện thoại',
                    tutor.soDienThoai,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.email_outlined,
                    'Email',
                    tutor.email,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    'Địa chỉ',
                    tutor.diaChi,
                  ),
                  const Divider(height: 25, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        Icons.phone,
                        'Gọi điện',
                        (tutor.soDienThoai?.isNotEmpty ?? false)
                            ? () => _makePhoneCall(context, tutor?.soDienThoai)
                            : null,
                      ),
                      _buildActionButton(
                        context,
                        Icons.mail,
                        'Gửi Mail',
                        (tutor.email?.isNotEmpty ?? false)
                            ? () => _sendEmail(context, tutor?.email)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Thông tin cá nhân
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        context,
                        Icons.person_outline,
                        'Giới tính',
                        tutor.displayGioiTinh,
                      ),
                      // Optional: Sử dụng hàm format ngày
                      _buildInfoRow(
                        context,
                        Icons.cake_outlined,
                        'Ngày sinh',
                        tutor.ngaySinh /* _formatDate(tutor.ngaySinh) */,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Kinh nghiệm & Bằng cấp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kinh nghiệm & Bằng cấp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        context,
                        Icons.school_outlined,
                        'Bằng cấp',
                        tutor.bangCap,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.work_outline,
                        'Kinh nghiệm',
                        tutor.kinhNghiem,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.book_outlined,
                        'Chuyên môn',
                        tutor.subject,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===> GIỮ LẠI CÁC ĐỊNH NGHĨA HÀM HELPER ĐẦY ĐỦ Ở CUỐI LỚP <===
  // Hàm helper để tạo một hàng thông tin
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Chưa cập nhật',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm helper để tạo nút hành động (Gọi, Mail)
  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  // Hàm xử lý gọi điện
  Future<void> _makePhoneCall(BuildContext context, String? phoneNumber) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Số điện thoại không có sẵn.')),
        );
      }
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    // Sử dụng launchUrl thay vì canLaunch + launch (cách mới hơn)
    try {
      await launchUrl(launchUri);
    } catch (e) {
      print('>>> Error launching phone call: $e'); // Ghi log lỗi
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Không thể thực hiện cuộc gọi: $e'),
          ), // Hiển thị lỗi cụ thể hơn
        );
      }
    }
  }

  // Hàm xử lý gửi email
  Future<void> _sendEmail(BuildContext context, String? email) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (email == null || email.isEmpty) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Địa chỉ email không có sẵn.')),
        );
      }
      return;
    }
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      // queryParameters: {'subject': 'Liên hệ về việc dạy kèm'} // Optional subject
    );
    // Sử dụng launchUrl thay vì canLaunch + launch
    try {
      await launchUrl(launchUri);
    } catch (e) {
      print('>>> Error launching email app: $e'); // Ghi log lỗi
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Không thể mở ứng dụng email: $e'),
          ), // Hiển thị lỗi cụ thể hơn
        );
      }
    }
  }

  // Optional: Hàm format ngày sinh
  // String _formatDate(String? dateString) {
  //   if (dateString == null || dateString.isEmpty) return 'Chưa cập nhật';
  //   try {
  //     final date = DateTime.parse(dateString);
  //     return DateFormat('dd/MM/yyyy').format(date);
  //   } catch (e) {
  //     return dateString;
  //   }
  // }
}
