// lib/pages/tutor_dashboard_page.dart

import 'package:flutter/material.dart';
// Import file widgets dùng chung
import '../widgets/home_widgets.dart';

class TutorDashboardPage extends StatefulWidget {
  final String userName;
  const TutorDashboardPage({super.key, required this.userName});

  @override
  State<TutorDashboardPage> createState() => _TutorDashboardPageState();
}

class _TutorDashboardPageState extends State<TutorDashboardPage> {
  int _currentIndex = 0;

  // Dữ liệu mẫu
  final List<Map<String, String>> classRequests = [
    {
      'classId': '0001',
      'studentName': 'Trần Minh Luân',
      'subject': 'Anh văn 12 + Toán',
      'location': 'Ấp 5, tân tây, gò công đông, tiền giang',
      'fee': '180,000 vnđ/Buổi',
      'receptionFee': '650,000 vnđ',
    },
    {
      'classId': '0002',
      'studentName': 'Nguyễn Thị B',
      'subject': 'Lý 11',
      'location': 'Quận 1, TP. Hồ Chí Minh',
      'fee': '200,000 vnđ/Buổi',
      'receptionFee': '700,000 vnđ',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(userName: widget.userName),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuSection(), // Sử dụng hàm riêng cho gọn
              const SizedBox(height: 24),
              const Text(
                'DANH SÁCH LỚP CHƯA GIAO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildClassRequestList(), // Sử dụng hàm riêng cho gọn
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // ✅ Đảm bảo khu vực Menu sử dụng MenuButton
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tái sử dụng MenuButton để tạo giao diện nút bấm
            MenuButton(icon: Icons.search, label: 'Tìm lớp học', onTap: () {}),
            MenuButton(icon: Icons.calendar_month, label: 'Lịch dạy', onTap: () {}),
            MenuButton(icon: Icons.school, label: 'Lớp của tôi', onTap: () {}),
          ],
        ),
      ],
    );
  }

  // Widget xây dựng danh sách các yêu cầu lớp học
  Widget _buildClassRequestList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classRequests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = classRequests[index];
        return ClassRequestCard(
          classId: request['classId']!,
          studentName: request['studentName']!,
          subject: request['subject']!,
          location: request['location']!,
          fee: request['fee']!,
          receptionFee: request['receptionFee']!,
        );
      },
    );
  }
}