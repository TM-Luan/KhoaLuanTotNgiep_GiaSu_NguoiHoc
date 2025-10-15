// lib/pages/student_home_page.dart

import 'package:flutter/material.dart';
import '../widgets/home_widgets.dart'; // Import file widgets mới

class StudentHomePage extends StatefulWidget {
  final String userName;
  const StudentHomePage({super.key, required this.userName});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentIndex = 0;

  // Giữ dữ liệu mẫu ở đây hoặc chuyển vào một ViewModel/Controller sau này
  final List<Map<String, String>> tutors = [
    {'image': 'assets/img/tutor1.png', 'name': 'Devon Lane', 'rating': '4.9', 'students': '15,844'},
    {'image': 'assets/img/tutor2.png', 'name': 'Darrell Steward', 'rating': '4.8', 'students': '12,021'},
    {'image': 'assets/img/tutor3.png', 'name': 'Jane Cooper', 'rating': '4.9', 'students': '22,671'},
    // Thêm các gia sư khác nếu cần
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
              const SearchBarWithFilter(),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 24),
              const Text(
                'DANH SÁCH GIA SƯ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTutorGrid(),
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

  // Widget để xây dựng khu vực Menu
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ✅ BIỂU TƯỢNG GIỮ NGUYÊN - ĐÃ KHỚP
            MenuButton(icon: Icons.person_search, label: 'Tìm gia sư', onTap: () {}),
            // ✅ ĐÃ CẬP NHẬT BIỂU TƯỢNG LỊCH
            MenuButton(icon: Icons.calendar_month, label: 'Lịch học', onTap: () {}),
            // ✅ ĐÃ CẬP NHẬT BIỂU TƯỢNG MŨ TỐT NGHIỆP
            MenuButton(icon: Icons.school, label: 'Lớp của tôi', onTap: () {}),
          ],
        ),
      ],
    );
  }

  // Widget để xây dựng lưới danh sách gia sư
  Widget _buildTutorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tutors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Hiển thị 3 gia sư trên một hàng
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7, // Điều chỉnh tỉ lệ để phù hợp hơn
      ),
      itemBuilder: (context, index) {
        final tutor = tutors[index];
        return TutorCard(
          imageUrl: tutor['image']!,
          name: tutor['name']!,
          rating: tutor['rating']!,
          studentCount: tutor['students']!,
        );
      },
    );
  }
}