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
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_schedule_page.dart';
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

  // --- Getters để lấy thông tin từ profile ---
  String get role {
    final userRole = currentProfile?.vaiTro ?? 0;
    if (userRole == 2) {
      return "gia sư";
    } else if (userRole == 3) {
      return "học viên";
    } else {
      return "người dùng";
    }
  }

  String get displayName {
    return currentProfile?.hoTen ?? 'Người dùng';
  }

  String get avatarText {
    final userName = currentProfile?.hoTen ?? '';
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

  List<Widget> get pages {
    final userRole = currentProfile?.vaiTro ?? 0;

    if (userRole == 2) {
      // Gia sư
      return [
        TutorHomePage(userProfile: currentProfile), // TRUYỀN PROFILE CHO TUTOR
        const TutorSchedulePage(),
        const TutorMyClassesScreen(),
        // const Placeholder(),
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
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen:
          (previousState, currentState) =>
              currentState is AuthAuthenticated ||
              currentState is AuthLoggedOut ||
              currentState is AuthError,
      listener: (context, state) {
        print(">>> [HomeScreen Listener] New Auth State: ${state.runtimeType}");
        if (state is AuthAuthenticated) {
          setState(() => currentProfile = state.user);
          print(
            ">>> [HomeScreen Listener] Profile Updated: ${currentProfile?.hoTen}, Role: ${currentProfile?.vaiTro}",
          );
        } else if (state is AuthLoggedOut) {
          print(">>> [HomeScreen Listener] Logged out, navigating to /login");
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthError) {
          print(">>> [HomeScreen Listener] Auth Error: ${state.message}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi xác thực: ${state.message}')),
            );
          }
          if (currentProfile == null) {
            print(
              ">>> [HomeScreen Listener] Error fetching profile, profile is null.",
            );
          }
        }
      },
      buildWhen: (previousState, currentState) => true,
      builder: (context, state) {
        print(
          ">>> [HomeScreen Builder] Building with Auth State: ${state.runtimeType}",
        );
        final isLoading = state is AuthLoading && currentProfile == null;
        print(">>> [HomeScreen Builder] isLoading: $isLoading");

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: pages[pageIndex],
          bottomNavigationBar: buildMyNavBar(context),
        );
      },
    );
  }

  // --- Bottom Navigation Bar ---
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.lightwhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha((255 * 0.1).round()),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(icon: Icons.home_filled, label: "Trang chủ", index: 0),
          buildNavItem(icon: Icons.calendar_today, label: "Lịch", index: 1),
          buildNavItem(icon: Icons.class_, label: "Lớp", index: 2),
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
    final isSelected = pageIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            pageIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : AppColors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlue : AppColors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
