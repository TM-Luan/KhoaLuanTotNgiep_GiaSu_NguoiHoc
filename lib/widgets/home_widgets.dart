// lib/widgets/home_widgets.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Widget cho AppBar tùy chỉnh
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  const CustomAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xin chào 👋',
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          Text(
            userName,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: AppColors.black),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Widget cho thanh tìm kiếm và bộ lọc
class SearchBarWithFilter extends StatelessWidget {
  const SearchBarWithFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm ở đây...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(25),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(25),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.filter_list, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget cho các nút chức năng trong Menu
class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

// Widget cho thẻ thông tin Gia sư (Dùng cho trang Sinh viên)
class TutorCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String rating;
  final String studentCount;

  const TutorCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.studentCount,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Code cho TutorCard giữ nguyên như cũ)
    return Container(); // Giữ code cũ ở đây
  }
}

// Widget cho Bottom Navigation Bar tùy chỉnh
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Lịch dạy'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Tin nhắn'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
      ],
    );
  }
}

// =======================================================================
// ✅ WIDGET MỚI: Thẻ hiển thị thông tin lớp học cần gia sư
// =======================================================================
class ClassRequestCard extends StatelessWidget {
  final String classId;
  final String studentName;
  final String subject;
  final String location;
  final String fee;
  final String receptionFee;

  const ClassRequestCard({
    super.key,
    required this.classId,
    required this.studentName,
    required this.subject,
    required this.location,
    required this.fee,
    required this.receptionFee,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã lớp: $classId - $subject',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person_outline, studentName),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.location_on_outlined, location),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: AppColors.primaryBlue, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.price_change_outlined, fee),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.business_center_outlined,
                        'Phí nhận lớp: $receptionFee'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Sử dụng ElevatedButton và style cho đồng bộ, không dùng CustomButton vì nó full-width
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Đề nghị dạy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget con để hiển thị thông tin có icon
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.grey, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}