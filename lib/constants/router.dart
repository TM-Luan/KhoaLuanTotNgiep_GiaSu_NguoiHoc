import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/login_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/register_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/splash_page.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
         case '/hometutor':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Trang không tồn tại')),
          ),
        );
    }
  }
}
