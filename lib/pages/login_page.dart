import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_imgs.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_button.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_text_field.dart';
import '../constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool rememberMe = false;

  // ✅ HÀM XỬ LÝ ĐĂNG NHẬP TẠM THỜI
  void _handleLogin() {
    final email = emailCtrl.text.trim().toLowerCase();

    // Lấy tên người dùng từ phần trước dấu @ của email để chào hỏi
    String userName = "User";
    if (email.isNotEmpty && email.contains('@')) {
      userName = email.split('@').first;
      // Viết hoa chữ cái đầu
      userName = "${userName[0].toUpperCase()}${userName.substring(1)}";
    }

    // =================================================================
    // TẠM THỜI: Logic chuyển trang dựa vào email nhập vào.
    // Sau này khi có database, bạn sẽ thay thế phần này.
    // =================================================================
    if (email.contains('tutor')) {
      // Nếu email có chữ "tutor", chuyển đến trang của gia sư
      Navigator.pushReplacementNamed(
        context,
        '/tutor-dashboard',
        arguments: {'userName': userName},
      );
    } else {
      // Ngược lại, chuyển đến trang của sinh viên
      Navigator.pushReplacementNamed(
        context,
        '/student-home',
        arguments: {'userName': userName},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset(AppImgs.logo, width: 80, height: 80),
              const SizedBox(height: 10),
              const Text('Đăng nhập', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 30),
              CustomTextField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: emailCtrl,
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Mật khẩu',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: passCtrl,
                maxLines: 1,
                keyboardType: TextInputType.visiblePassword,
              ),
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppColors.primaryBlue,
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
              // ✅ GỌI HÀM _handleLogin KHI NHẤN NÚT
              CustomButton(text: 'ĐĂNG NHẬP', onPressed: _handleLogin),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không có tài khoản? '),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}