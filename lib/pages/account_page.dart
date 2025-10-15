// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final String _userName = 'Trần Minh Luân';
  final bool _isLoggedIn = true; 

  // void _logout() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Chức năng Đăng xuất chưa khả dụng (Chờ API)')),
  //   );
  // }

  void _onAvatarTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chọn ảnh từ thư viện (Chờ API)')),
    );
  }

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
            style: const TextStyle(fontSize: 16, color: AppColors.black),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.lightGrey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                InkWell(
                  onTap: _onAvatarTap,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildAccountItem(
            title: 'Trang cá nhân',
            icon: Icons.home_outlined,
            onTap: () {},
          ),
          _buildAccountItem(
            title: 'Chỉnh sửa thông tin',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          _buildAccountItem(
            title: 'Đổi mật khẩu',
            icon: Icons.more_horiz,
            onTap: () {},
          ),
          if (_isLoggedIn)
            _buildAccountItem(
              title: 'Đăng xuất',
              icon: Icons.exit_to_app,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang chờ API Đăng xuất!')),
                );
              },
            ),
          
          const Spacer(),

          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3), 
              border: const Border(top: BorderSide(color: AppColors.lightGrey, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(icon: Icons.home, label: 'Trang chủ', isSelected: false),
                _buildNavItem(icon: Icons.person, label: 'Tài khoản', isSelected: true),
                _buildNavItem(icon: Icons.settings, label: 'Cài đặt', isSelected: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isSelected}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.primaryBlue : AppColors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : AppColors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}