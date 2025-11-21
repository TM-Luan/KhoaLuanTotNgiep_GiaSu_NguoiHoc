import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
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
    _initApp();
  }

  Future<void> _initApp() async {
    // Bước 1: Kiểm tra Token trong bộ nhớ máy
    final token = await SecureStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Bước 2A: CÓ TOKEN -> Gọi AuthBloc để tải thông tin profile ngay lập tức
      // Việc chuyển màn hình sẽ do BlocListener (bên dưới) xử lý khi có kết quả
      context.read<AuthBloc>().add(const FetchProfileRequested());
    } else {
      // Bước 2B: KHÔNG CÓ TOKEN -> Chờ nhẹ 1.5s cho hiện logo rồi về Login
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _navigateToLogin();
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Lắng nghe kết quả từ FetchProfileRequested
        if (state is AuthAuthenticated) {
          _navigateToHome();
        } else if (state is AuthError) {
          _navigateToLogin();
        }
      },
      child: Scaffold(
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
              const Text(
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
      ),
    );
  }
}