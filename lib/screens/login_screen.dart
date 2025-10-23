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

    print('🔐 Attempting login with email: $email');

    if (email.isEmpty || pass.isEmpty) {
      print('❌ Empty email or password');
      _showSnackBar('Vui lòng nhập đầy đủ Email và Mật khẩu');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final repo = AuthRepository();
      print('📡 Calling login API...');
      final res = await repo.login(email, pass);

      print('📊 Login API response:');
      print('  - success: ${res.success}');
      print('  - message: ${res.message}');
      print('  - data: ${res.data}');
      print('  - data type: ${res.data?.runtimeType}');

      if (!mounted) {
        print('❌ Context not mounted after API call');
        return;
      }

      if (res.success && res.data != null) {
        print('✅ Login successful, saving token...');
        await SecureStorage.saveToken(res.data!.token);

        // Verify token was saved
        final savedToken = await SecureStorage.getToken();
        print('💾 Token saved: ${savedToken != null && savedToken.isNotEmpty}');
        print('📝 Token length: ${savedToken?.length}');

        _showSnackBar(res.message ?? 'Đăng nhập thành công');

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) {
          print('❌ Context not mounted after delay');
          return;
        }

        print('🔄 Starting navigation to HomePage...');

        // THỬ CÁCH 1: Navigation đơn giản
        try {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
          print('✅ Navigation command executed');
        } catch (e) {
          print('❌ Navigation error: $e');
        }
      } else {
        print('❌ Login failed in API response');
        _showSnackBar(res.message ?? 'Đăng nhập thất bại');
      }
    } catch (e, stackTrace) {
      print('❌ Login exception: $e');
      print('📋 Stack trace: $stackTrace');
      if (!mounted) return;
      _showSnackBar('Lỗi: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('🔄 Loading state set to false');
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
