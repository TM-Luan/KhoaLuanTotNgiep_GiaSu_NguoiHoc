// screens/home_screen.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/auth/account_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_my_classes_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_home_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_home_page_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_my_classes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  UserProfile? currentProfile;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const FetchProfileRequested());
  }

  List<Widget> get pages {
    final userRole = currentProfile?.vaiTro ?? 0;

    if (userRole == 2) {
      // Gia sư
      return [
        TutorHomePage(userProfile: currentProfile),
        const TutorSchedulePage(),
        const TutorMyClassesScreen(),
        const Account(),
      ];
    } else if (userRole == 3) {
      // Học viên
      return [
        LearnerHomeScreen(userProfile: currentProfile),
        const LearnerSchedulePage(),
        const StudentMyClassesPage(),
        const Account(),
      ];
    } else {
      // Fallback hoặc Loading
      return [
        const Scaffold(body: Center(child: CircularProgressIndicator())),
        const Scaffold(body: Center(child: CircularProgressIndicator())),
        const Scaffold(body: Center(child: CircularProgressIndicator())),
        const Account(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen:
          (previousState, currentState) =>
              currentState is AuthAuthenticated ||
              currentState is AuthLoggedOut ||
              currentState is AuthError,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() => currentProfile = state.user);
        } else if (state is AuthLoggedOut) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi xác thực: ${state.message}')),
            );
          }
        }
      },
      buildWhen: (previousState, currentState) => true,
      builder: (context, state) {
        final isLoading = state is AuthLoading && currentProfile == null;

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white, // Nền sạch
          body: pages[pageIndex],
          bottomNavigationBar: _buildModernNavBar(context),
        );
      },
    );
  }

  // --- Modern Bottom Navigation Bar ---
  Widget _buildModernNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ), // Bóng mờ nhẹ nhàng hơn
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65, // Chiều cao vừa phải
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                activeIcon: Icons.home_rounded,
                label: "Trang chủ",
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.calendar_today_rounded,
                activeIcon: Icons.calendar_month_rounded,
                label: "Lịch",
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.class_outlined,
                activeIcon: Icons.class_rounded,
                label: "Lớp học",
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: "Tài khoản",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = pageIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey.shade400;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            pageIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque, // Tăng vùng bấm
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 0 : 2), // Hiệu ứng nảy nhẹ
              child: Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
