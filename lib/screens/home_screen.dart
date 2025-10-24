import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/account_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_my_classes_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_home_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;
  Profile? currentProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final repo = AuthRepository();
      final response = await repo.getProfile();

      setState(() {
        if (response.success && response.data != null) {
          currentProfile = response.data;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String get role {
    final userRole = currentProfile?.data?.vaiTro ?? 0;
    if (userRole == 2) {
      return "gia sư";
    } else if (userRole == 3) {
      return "học viên";
    } else {
      return "người dùng";
    }
  }

  String get displayName {
    return currentProfile?.data?.hoTen ?? 'Người dùng';
  }

  String get avatarText {
    final userName = currentProfile?.data?.hoTen ?? '';
    return userName.isNotEmpty ? userName[0] : 'U';
  }

  List<Widget> get pages {
    final userRole = currentProfile?.data?.vaiTro ?? 0;

    if (userRole == 2) {
      return [
        const TutorListPage(),
        const TutorSchedulePage(),
        const Placeholder(),
        const Account(),
      ];
    } else if (userRole == 3) {
      return [
        const LearnerHomePage(),
        const LearnerSchedulePage(),
        const StudentMyClassesPage(),
        const Account(),
      ];
    } else {
      return [
        const Center(child: Text('Vui lòng cập nhật vai trò')),
        const Center(child: Text('Vui lòng cập nhật vai trò')),
        const Center(child: Text('Vui lòng cập nhật vai trò')),
        const Account(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: CircleAvatar(
          child: Text(avatarText, style: TextStyle(color: AppColors.white)),
        ),
        title: Text(
          "Xin chào, $displayName",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
            color: AppColors.white,
          ),
        ],
      ),
      body: pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.lightwhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(icon: Icons.home_filled, label: "Trang chủ", index: 0),
          buildNavItem(icon: Icons.calendar_today, label: "Lịch", index: 1),
          buildNavItem(icon: Icons.table_chart, label: "Lớp", index: 2),
          buildNavItem(icon: Icons.person, label: "Tài khoản", index: 3),
        ],
      ),
    );
  }

  Widget buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          pageIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: pageIndex == index ? AppColors.lightBlue : AppColors.black,
            size: 30,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: pageIndex == index ? AppColors.lightBlue : AppColors.black,
              fontSize: 12,
              fontWeight:
                  pageIndex == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
