import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/auth/change_password_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/auth/edit_profile_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/auth/profile_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/home/splash_screen.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final AuthRepository _repo = AuthRepository();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final res = await _repo.getProfile();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          _profile = res.data;
        }
      });
    }
  }

  String _getRoleText(int? vaiTro) {
    switch (vaiTro) {
      case 2:
        return "Gia sư";
      case 3:
        return "Học viên";
      default:
        return "Người dùng";
    }
  }

  // --- LOGIC LOGOUT ---
  void _handleLogout() async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      await _repo.logout(token); // Gọi API (có thể bỏ qua lỗi để force logout)
    }

    await SecureStorage.deleteToken();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đăng xuất thành công"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Xám rất nhạt (Modern Grey)
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // --- SECTION 1: HEADER PROFILE ---
            _buildProfileHeader(),

            const SizedBox(height: 30),

            // --- SECTION 2: MENU ACTIONS ---
            _buildSectionTitle("Cài đặt chung"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    title: 'Trang cá nhân',
                    subtitle: 'Xem chi tiết hồ sơ công khai',
                    icon: Icons.person_outline_rounded,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    title: 'Chỉnh sửa thông tin',
                    subtitle: 'Cập nhật hồ sơ của bạn',
                    icon: Icons.edit_outlined,
                    onTap: () async {
                      if (_profile == null) return;
                      final updated = await Navigator.push<UserProfile?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(user: _profile!),
                        ),
                      );
                      if (updated != null && mounted) {
                        setState(() => _profile = updated);
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    title: 'Đổi mật khẩu',
                    subtitle: 'Bảo mật tài khoản',
                    icon: Icons.lock_outline_rounded,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- SECTION 3: LOGOUT ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildMenuItem(
                title: 'Đăng xuất',
                icon: Icons.logout_rounded,
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent,
                hideArrow: true,
                onTap: _handleLogout,
              ),
            ),

            const SizedBox(height: 40),
            Text(
              "Phiên bản 1.0.0",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            child:
                (_profile?.anhDaiDien?.isNotEmpty == true)
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _profile!.anhDaiDien!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        memCacheWidth: 240,
                        memCacheHeight: 240,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey.shade400,
                            ),
                      ),
                    )
                    : Icon(Icons.person, size: 50, color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          _profile?.hoTen ?? "Người dùng",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        // Role Badge (Modern Chip style)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Text(
            _getRoleText(_profile?.vaiTro),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool hideArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!hideArrow)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 60,
    );
  }
}
