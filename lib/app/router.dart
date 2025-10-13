import 'package:flutter/material.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/pages/welcome_page.dart';
import '../features/auth/pages/register_tutor_page.dart'; // THÊM DÒNG NÀY

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      
      // THÊM CASE MỚI Ở ĐÂY
      case '/register_tutor':
        return MaterialPageRoute(builder: (_) => const RegisterTutorPage());

      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(child: Text('Trang không tồn tại')),
                ));
    }
  }
}