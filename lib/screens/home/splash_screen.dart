import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_imgs.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/home/home_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/auth/login_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Hiệu ứng chờ nhẹ
    final token = await SecureStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GIA SƯ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kết nối người học',
              style: TextStyle(color: AppColors.black, fontSize: 14),
            ),
            const SizedBox(height: 30),
            Image.asset(AppImgs.logo, width: 100, height: 100),
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}
