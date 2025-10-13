import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GIA SƯ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kết nối người học',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            Image.asset('assets/logo.png', width: 100, height: 100),            const SizedBox(height: 60),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              icon: const Icon(Icons.arrow_forward, color: AppColors.white),
              label: const Text(
                "Tiếp tục ứng dụng",
                style: TextStyle(color: AppColors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
