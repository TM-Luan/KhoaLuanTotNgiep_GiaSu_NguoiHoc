import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/account_page.dart';
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