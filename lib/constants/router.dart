import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/account_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/student_class_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/student_my_classes_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/tutor_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/tutor_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/login_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/register_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/splash_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/student_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/learner_schedule_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/tutor_schedule_page.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/student':
        return MaterialPageRoute(builder: (_) => const LearnerHomePage()); 
      case '/tutor':
        return MaterialPageRoute(builder: (_) => const TutorListPage()); 
      case '/TutorDetail':
        return MaterialPageRoute(builder: (_) => const TutorDetailPage());
      case '/account':
        return MaterialPageRoute(builder: (_) => const AccountPage());
      
      case '/learnerSchedule':
        return MaterialPageRoute(builder: (_) => const LearnerSchedulePage());
      case '/tutorSchedule': 
        return MaterialPageRoute(builder: (_) => const TutorSchedulePage());
      case '/my-classes':
        return MaterialPageRoute(builder: (_) => const StudentMyClassesPage());
        
      // THÊM ROUTE CHO TRANG CHI TIẾT LỚP HỌC
      case '/class-detail':
        // Lấy dữ liệu ClassDetail được truyền qua arguments
        final classDetail = settings.arguments as ClassDetail; 
        return MaterialPageRoute(
          builder: (_) => ClassDetailPage(classDetail: classDetail),
        );


      default:
        return MaterialPageRoute(
          builder: (
            _
          ) =>
              const Scaffold(
            body: Center(child: Text('Trang không tồn tại')),
          ),
        );
    }
  }
}