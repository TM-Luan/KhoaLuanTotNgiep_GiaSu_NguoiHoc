import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_imgs.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool agreeTerms = false;
  bool isLoading = false;
  String role = '';

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(AppImgs.logo, width: 80, height: 80),
            const SizedBox(height: 10),
            const Text('Đăng ký', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 30),

            // Chọn vai trò
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Gia sư'),
                    value: '2',
                    groupValue: role,
                    onChanged: (value) => setState(() => role = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Học viên'),
                    value: '3',
                    groupValue: role,
                    onChanged: (value) => setState(() => role = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            CustomTextField(
              label: 'Họ tên',
              icon: Icons.person_outline,
              controller: nameCtrl,
              maxLines: 1,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLines: 1,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
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
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Xác nhận mật khẩu',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: confirmPassCtrl,
              maxLines: 1,
              keyboardType: TextInputType.visiblePassword,
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: agreeTerms,
                  onChanged:
                      (value) => setState(() => agreeTerms = value ?? false),
                  activeColor: AppColors.primaryBlue,
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      const Text('Tôi đồng ý các '),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'quy định',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              CustomButton(text: 'Đăng ký', onPressed: _handleRegister),

            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Đã có tài khoản? '),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final hoTen = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final matKhau = passCtrl.text.trim();
    final confirmPass = confirmPassCtrl.text.trim();
    final soDienThoai = phoneCtrl.text.trim();
    final vaiTro = int.tryParse(role) ?? 0;

    // Kiểm tra hợp lệ
    if (hoTen.isEmpty ||
        email.isEmpty ||
        matKhau.isEmpty ||
        confirmPass.isEmpty ||
        soDienThoai.isEmpty ||
        vaiTro == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (matKhau != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    if (matKhau.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')),
      );
      return;
    }

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý điều khoản')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final repo = AuthRepository();
      final res = await repo.register(
        hoTen: hoTen,
        email: email,
        matKhau: matKhau,
        confirmPass: confirmPass,
        soDienThoai: soDienThoai,
        vaiTro: vaiTro,
      );

      if (!context.mounted) return;

      if (res.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.message)));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.message)));
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }
}
