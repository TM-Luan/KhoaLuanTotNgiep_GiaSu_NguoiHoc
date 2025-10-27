import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/home_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/profile_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_my_classes_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/login_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/register_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/splash_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_home_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_schedule_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/student':
        return MaterialPageRoute(builder: (_) => const LearnerHomeScreen());
      case '/tutor':
        return MaterialPageRoute(builder: (_) => const TutorListPage());
      case '/TutorDetail':
        return MaterialPageRoute(builder: (_) => const TutorDetailPage());

      case '/learnerSchedule':
        return MaterialPageRoute(builder: (_) => const LearnerSchedulePage());
      case '/tutorSchedule':
        return MaterialPageRoute(builder: (_) => const TutorSchedulePage());
      case '/my-classes':
        return MaterialPageRoute(builder: (_) => const StudentMyClassesPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // THÊM ROUTE CHO TRANG CHI TIẾT LỚP HỌC
      case '/class-detail':
        // Lấy dữ liệu ClassDetail được truyền qua arguments
        final classDetail = settings.arguments as ClassDetail;
        return MaterialPageRoute(
          builder: (_) => ClassDetailPage(classDetail: classDetail),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Trang không tồn tại')),
              ),
        );
    }
  }
}
