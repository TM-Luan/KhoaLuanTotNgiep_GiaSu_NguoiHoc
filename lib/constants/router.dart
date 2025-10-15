import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/home_tutor_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/login_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/register_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/splash_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/student_home_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      // ✅ THÊM ROUTE CHO TRANG CHỦ SINH VIÊN
      case '/student-home':
        // Lấy dữ liệu được truyền qua arguments
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => StudentHomePage(
            userName: args?['userName'] ?? 'Học viên', // Tên mặc định
          ),
        );

      // ✅ THÊM ROUTE CHO TRANG CHỦ GIA SƯ (thay thế cho '/hometutor')
      case '/tutor-dashboard':
        // Lấy dữ liệu được truyền qua arguments
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TutorDashboardPage(
            userName: args?['userName'] ?? 'Gia sư', // Tên mặc định
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Trang không tồn tại')),
          ),
        );
    }
  }
}