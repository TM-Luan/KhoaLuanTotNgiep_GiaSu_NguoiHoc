import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/widgets/custom_button.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/features/auth/widgets/custom_text_field.dart';


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
  String role = 'gia_su'; // mặc định là Gia sư

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Nhập thông tin của bạn:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            // Lựa chọn vai trò
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Gia sư'),
                    value: 'gia_su',
                    groupValue: role,
                    onChanged: (value) {
                      setState(() => role = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Học viên'),
                    value: 'hoc_vien',
                    groupValue: role,
                    onChanged: (value) {
                      setState(() => role = value!);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            CustomTextField(
              label: 'Họ tên (bắt buộc)*',
              icon: Icons.person_outline,
              controller: nameCtrl,
              maxLines: 1,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Số điện thoại (bắt buộc)*',
              icon: Icons.phone_outlined,
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLines: 1,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Email (nên nhập)',
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
              maxLines: 1, keyboardType: null,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Xác nhận mật khẩu',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: confirmPassCtrl,
              maxLines: 1, keyboardType: null,
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: agreeTerms,
                  onChanged: (value) {
                    setState(() => agreeTerms = value ?? false);
                  },
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
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const Text(' của HTCon.'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            CustomButton(
              text: 'Đăng ký',
              onPressed: () {
                if (!agreeTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng đồng ý với quy định.')),
                  );
                  return;
                }

                // Sau khi đăng ký có thể điều hướng sang màn hình riêng:
             // Sau khi đăng ký thành công thì quay về màn hình đăng nhập
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng ký thành công!')),
                );
                Navigator.pushReplacementNamed(context, '/login');

                              },
                            ),

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
}
