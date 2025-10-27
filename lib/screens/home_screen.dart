import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth_state.dart';

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/account_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_my_classes_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_home_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_schedule_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  UserProfile? currentProfile;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const FetchProfileRequested());
  }

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
    return userName.isNotEmpty ? userName[0] : 'U';
  }

  List<Widget> get pages {
    final userRole = currentProfile?.vaiTro ?? 0;

    if (userRole == 2) {
      return const [
        TutorListPage(),
        TutorSchedulePage(),
        Placeholder(),
        Account(),
      ];
    } else if (userRole == 3) {
      return const [
        LearnerHomeScreen(),
        LearnerSchedulePage(),
        StudentMyClassesPage(),
        Account(),
      ];
    } else {
      return const [
        Center(child: Text('Vui lòng cập nhật vai trò')),
        Center(child: Text('Vui lòng cập nhật vai trò')),
        Center(child: Text('Vui lòng cập nhật vai trò')),
        Account(),
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
      listener: (context, currentState) {
        if (currentState is AuthAuthenticated) {
          setState(() => currentProfile = currentState.user);
        } else if (currentState is AuthLoggedOut) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (currentState is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentState.message)));
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
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(child: Text(avatarText)),
                const SizedBox(width: 10),
                Text('Xin chào, $displayName'),
              ],
            ),
          ),
          body: pages[pageIndex],
          bottomNavigationBar: buildMyNavBar(context),
        );
      },
    );
  }

  // ------------------ NAV BAR TÙY CHỈNH ------------------

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
            color: Colors.black.withOpacity(0.1),
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
