// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
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

  Widget _buildAccountItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(
                  AppSpacing.iconContainerRadius,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.iconSize,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: AppTypography.body1,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: AppSpacing.smallIconSize,
              color: AppColors.textMuted,
            ),
            onTap: onTap,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'THÔNG TIN CÁ NHÂN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppTypography.appBarTitle,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header với nền xám đẹp
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.grey100,
                    AppColors.grey50,
                    AppColors.background,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    // Profile Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 4,
                          ),
                        ),
                        child:
                            _profile?.anhDaiDien?.isNotEmpty == true
                                ? CircleAvatar(
                                  radius: 55,
                                  backgroundColor: AppColors.primarySurface,
                                  backgroundImage: NetworkImage(
                                    _profile!.anhDaiDien!,
                                  ),
                                  onBackgroundImageError: (_, __) {},
                                )
                                : CircleAvatar(
                                  radius: 55,
                                  backgroundColor: AppColors.primarySurface,
                                  child: Icon(
                                    Icons.person,
                                    size: 55,
                                    color: AppColors.primary,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // User Name
                    Text(
                      _profile?.hoTen ?? "Người dùng",
                      style: TextStyle(
                        fontSize: AppTypography.heading1,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // User Role
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.primary],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.buttonBorderRadius * 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getRoleText(_profile?.vaiTro),
                        style: TextStyle(
                          fontSize: AppTypography.body1,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Menu Items
            _buildAccountItem(
              title: 'Trang cá nhân',
              icon: Icons.person_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            _buildAccountItem(
              title: 'Chỉnh sửa thông tin',
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
            _buildAccountItem(
              title: 'Đổi mật khẩu',
              icon: Icons.lock_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                );
              },
            ),
            _buildAccountItem(
              title: 'Đăng xuất',
              icon: Icons.exit_to_app,
              onTap: () async {
                final token = await SecureStorage.getToken();
                if (token == null) return;
                final res = await _repo.logout(token);

                if (!context.mounted) return;
                final msg = (res.message);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: Colors.green),
                );
                await SecureStorage.deleteToken();

                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SplashPage()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
