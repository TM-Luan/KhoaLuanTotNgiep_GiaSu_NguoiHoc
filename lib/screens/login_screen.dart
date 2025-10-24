import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_imgs.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/home_screen.dart';
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
  bool isLoading = false;

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
              if (isLoading)
                const CircularProgressIndicator()
              else
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

  Future<void> _handleLogin() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ Email và Mật khẩu');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final repo = AuthRepository();
      final res = await repo.login(email, pass);
      if (!mounted) {
        return;
      }

      if (res.success && res.data != null) {
        await SecureStorage.saveToken(res.data!.token);

        _showSnackBar(res.message);

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        _showSnackBar(res.message);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Helper method để hiển thị snackbar an toàn
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
