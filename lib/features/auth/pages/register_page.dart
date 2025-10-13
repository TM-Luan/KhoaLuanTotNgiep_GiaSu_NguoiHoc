import 'package:flutter/material.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_colors.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Đăng ký'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/logo.png', width: 80, height: 80),
            const SizedBox(height: 10),
            const Text('Đăng ký', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 30),
            CustomTextField(label: 'Email', icon: Icons.email, controller: emailCtrl),
            const SizedBox(height: 15),
            CustomTextField(label: 'Số điện thoại', icon: Icons.phone, controller: phoneCtrl),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Mật khẩu',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: passCtrl,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('TIẾP TỤC'),
            ),
          ],
        ),
      ),
    );
  }
}
