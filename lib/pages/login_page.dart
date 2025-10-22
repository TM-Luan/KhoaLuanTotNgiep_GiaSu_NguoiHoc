import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_imgs.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
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
              CustomButton(
                text: 'ĐĂNG NHẬP',
                onPressed: () async {
  final email = emailCtrl.text.trim();
  final pass = passCtrl.text.trim();

  if (email.isEmpty || pass.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng nhập đầy đủ Email và Mật khẩu')),
    );
    return;
  }

  final repo = AuthRepository();
  final res = await repo.login(email, pass);

  // Kiểm tra nếu widget đã dispose
  if (!context.mounted) return;

  if (res.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xin chào: ${res.data?.email}')),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message ?? 'Đăng nhập thất bại')),
    );
  }
},

              ),

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
