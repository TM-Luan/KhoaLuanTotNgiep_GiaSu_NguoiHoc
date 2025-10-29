// constants/router.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/login_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/splash_screen.dart';
// ... (các import khác giữ nguyên) ...
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_class_detail_screen.dart'; 


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // ===> KIỂM TRA CÁC LỆNH PRINT NÀY <===
    print('>>> [Router] Generating route for: ${settings.name}');
    print('>>> [Router] Arguments received: ${settings.arguments}');
    // =====================================

    switch (settings.name) {
      // ... (các case khác giữ nguyên) ...
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      // ... (thêm các case khác nếu có)

      case TutorDetailPage.routeName: // '/tutor-detail'
         // ===> KIỂM TRA CÁC LỆNH PRINT NÀY <===
         print('>>> [Router] Matched route: ${TutorDetailPage.routeName}');
         Object? args = settings.arguments;
         print('>>> [Router] Raw arguments type: ${args?.runtimeType}');
         // =====================================

         Tutor? tutor;
         if (args is Tutor) {
           tutor = args;
           print('>>> [Router] Successfully cast arguments to Tutor: ${tutor.name}');
         } else {
           print('>>> [Router] FAILED to cast arguments to Tutor.');
         }

         if (tutor != null) {
            print('>>> [Router] Building TutorDetailPage...');
            return MaterialPageRoute(
               settings: settings,
               builder: (_) => const TutorDetailPage() // Chỉ cần tạo instance
            );
         }
         print('>>> [Router] Arguments invalid or null. Building error route...');
         return _errorRoute('Dữ liệu gia sư không hợp lệ');

      case '/class-detail':
        // ... (Giữ nguyên logic cho class detail) ...
         print('>>> [Router] Matched route: /class-detail');
        final classDetail = settings.arguments as ClassDetail?;
         print('>>> [Router] Received ClassDetail arguments: ${classDetail?.name}');
        if (classDetail != null) {
          print('>>> [Router] Building ClassDetailPage...');
          return MaterialPageRoute(
             settings: settings,
             builder: (_) => ClassDetailPage(classDetail: classDetail),
          );
        }
         print('>>> [Router] ClassDetail arguments invalid or null. Building error route...');
        return _errorRoute('Dữ liệu lớp học không hợp lệ');


      default:
        print('>>> [Router] Route ${settings.name} not found. Building default error route...');
        return _errorRoute('Trang không tồn tại (${settings.name})');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
     // ... (Giữ nguyên)
     return MaterialPageRoute(
        builder: (_) => Scaffold(
           appBar: AppBar(title: const Text('Lỗi')),
           body: Center(child: Text(message)),
        ),
     );
  }
}