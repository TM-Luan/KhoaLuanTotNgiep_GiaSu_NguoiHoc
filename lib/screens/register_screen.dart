import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_imgs.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_button.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool agreeTerms = false;
  String role = ''; // '2' gia sư, '3' học viên

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            _showSnackBar(state.message);
            Navigator.pop(context); // quay lại login
          } else if (state is AuthError) {
            _showSnackBar(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
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
                      onChanged: (v) => setState(() => agreeTerms = v ?? false),
                      activeColor: AppColors.primaryBlue,
                    ),
                    const Expanded(child: Text('Tôi đồng ý với điều khoản')),
                  ],
                ),

                const SizedBox(height: 10),

                if (isLoading)
                  const CircularProgressIndicator()
                else
                  CustomButton(text: 'ĐĂNG KÝ', onPressed: _onRegisterPressed),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onRegisterPressed() {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final confirm = confirmPassCtrl.text.trim();

    if (role.isEmpty) {
      _showSnackBar('Vui lòng chọn vai trò');
      return;
    }
    if ([name, phone, email, pass, confirm].any((e) => e.isEmpty)) {
      _showSnackBar('Vui lòng nhập đủ thông tin');
      return;
    }
    if (pass != confirm) {
      _showSnackBar('Mật khẩu không khớp');
      return;
    }
    if (!agreeTerms) {
      _showSnackBar('Vui lòng đồng ý điều khoản');
      return;
    }

    context.read<AuthBloc>().add(
      RegisterRequested(
        hoTen: name,
        email: email,
        matKhau: pass,
        confirmPass: confirm,
        soDienThoai: phone,
        vaiTro: int.tryParse(role) ?? 3,
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
