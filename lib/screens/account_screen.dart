import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/profile_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/splash_screen.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Widget _buildAccountItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.black),
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, color: AppColors.black),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: AppColors.grey,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.lightGrey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAccountItem(
              title: 'Trang cá nhân',
              icon: Icons.home_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            _buildAccountItem(
              title: 'Chỉnh sửa thông tin',
              icon: Icons.description_outlined,
              onTap: () {},
            ),
            _buildAccountItem(
              title: 'Đổi mật khẩu',
              icon: Icons.lock_outline,
              onTap: () {},
            ),
            _buildAccountItem(
              title: 'Đăng xuất',
              icon: Icons.exit_to_app,
              onTap: () async {
                final repo = AuthRepository();
                final token = await SecureStorage.getToken();
                if (token == null) return;
                final res = await repo.logout(token);
                if (!context.mounted) return;
                final msg =
                    res.success ? (res.data ?? 'Đã đăng xuất') : (res.message);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
                await SecureStorage.deleteToken();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SplashPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
