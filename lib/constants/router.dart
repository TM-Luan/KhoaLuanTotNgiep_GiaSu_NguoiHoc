// FILE: router.dart
// (Đã xóa bỏ case '/class-detail' gây lỗi)

import 'package:flutter/material.dart';
// Import các màn hình bạn thực sự dùng
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/login_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/splash_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/register_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_home_screen.dart'; // LearnerHomeScreen
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_home_page.dart';     // TutorHomePage (thay vì TutorListPage)
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_schedule_screen.dart'; // LearnerSchedulePage
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_schedule_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_my_classes_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/home_screen.dart'; // Có thể là màn hình chung?
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/profile_screen.dart';

// KHÔNG CẦN import giasu.dart hay student_class_detail_screen.dart ở đây nữa
// vì chúng không được dùng trực tiếp trong generateRoute

class AppRouter {
 static Route<dynamic> generateRoute(RouteSettings settings) {
   print('>>> [Router] Generating route for: ${settings.name}');
   print('>>> [Router] Arguments received: ${settings.arguments}');

   switch (settings.name) {
     case '/splash':
       return MaterialPageRoute(builder: (_) => const SplashPage());
     case '/login':
       return MaterialPageRoute(builder: (_) => const LoginScreen());
     case '/register':
       return MaterialPageRoute(builder: (_) => const RegisterScreen());
     case '/student': // Trang chủ người học
       return MaterialPageRoute(builder: (_) => const LearnerHomeScreen());
     case '/tutor': // Trang chủ gia sư (danh sách lớp)
       return MaterialPageRoute(builder: (_) => const TutorHomePage()); // Dùng tên mới
     case '/TutorDetail': // Route này có vẻ không được dùng, xem xét xóa?
       return MaterialPageRoute(builder: (_) => const TutorDetailPage());

     case '/learnerSchedule':
       return MaterialPageRoute(builder: (_) => const LearnerSchedulePage());
     case '/tutorSchedule':
       return MaterialPageRoute(builder: (_) => const TutorSchedulePage());
     case '/my-classes': // Lớp của tôi (học sinh)
       return MaterialPageRoute(builder: (_) => const StudentMyClassesPage());
     case '/home': // Trang home chung?
       return MaterialPageRoute(builder: (_) => const HomeScreen());
     case '/profile':
       return MaterialPageRoute(builder: (_) => const ProfileScreen());

     // === ĐÃ XÓA BỎ CASE '/class-detail' GÂY LỖI TẠI ĐÂY ===

     // Case cho TutorDetailPage (Ví dụ nếu bạn muốn dùng pushNamed)
     // case TutorDetailPage.routeName: // '/tutor-detail'
     //    final tutor = settings.arguments as Tutor?; // Lấy Tutor
     //    if (tutor != null) {
     //      return MaterialPageRoute(
     //        settings: settings,
     //        builder: (_) => TutorDetailPage(tutor: tutor), // Truyền tutor vào
     //      );
     //    }
     //    return _errorRoute('Dữ liệu gia sư không hợp lệ');

     default:
       print('>>> [Router] Route ${settings.name} not found. Building default error route...');
       return _errorRoute('Trang không tồn tại (${settings.name})');
   }
 }

 static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text(message)),
      ),
    );
 }
}