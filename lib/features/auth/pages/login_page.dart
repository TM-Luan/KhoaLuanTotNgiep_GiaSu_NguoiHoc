import 'package:flutter/material.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool rememberMe = false; // Thêm trạng thái cho checkbox

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Đăng nhập'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/logo.png', width: 80, height: 80), // Thay biểu tượng sách
            const SizedBox(height: 10),
            const Text('Đăng nhập', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 30),
            CustomTextField(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: emailCtrl,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Mật khẩu',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: passCtrl,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value ?? false; // Cập nhật trạng thái khi tích
                    });
                  },
                  activeColor: Colors.purple, // Màu tím khi tích
                ),
                const Text('Nhớ mật khẩu'),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Quên mật khẩu?'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('ĐĂNG NHẬP'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Không có tài khoản? '),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/welcome'),
                  child: const Text(
                    'Đăng ký ngay',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}