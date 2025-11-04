import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Lấy hồ sơ từ BLoC
    context.read<AuthBloc>().add(const FetchProfileRequested());
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

  String _getGenderText(String? gioiTinh) {
    switch (gioiTinh) {
      case 'M':
        return "Nam";
      case 'F':
        return "Nữ";
      default:
        return "Chưa cập nhật";
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "Chưa cập nhật";
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previousState, currentState) => true,
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        UserProfile? userData;
        if (state is AuthAuthenticated) {
          userData = state.user;
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            title: Text("Trang cá nhân",
              style: TextStyle(
                fontSize: AppTypography.appBarTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: AppColors.backgroundGrey,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Profile Avatar Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProfilePic(
                        image: userData?.anhDaiDien ??
                            "https://i.postimg.cc/cCsYDjvj/user-2.png",
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        userData?.hoTen ?? "Chưa có tên",
                        style: TextStyle(
                          fontSize: AppTypography.heading1,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
                        ),
                        child: Text(
                          _getRoleText(userData?.vaiTro),
                          style: TextStyle(
                            fontSize: AppTypography.body2,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Thông tin cá nhân Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.iconContainerRadius),
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: AppSpacing.iconSize,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            "Thông tin cá nhân",
                            style: TextStyle(
                              fontSize: AppTypography.heading3,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Info(
                        infoKey: "Mã tài khoản",
                        info: userData?.taiKhoanID?.toString() ?? "Chưa cập nhật",
                      ),
                      Info(
                        infoKey: "Email",
                        info: userData?.email ?? "Chưa cập nhật",
                      ),
                      Info(
                        infoKey: "Số điện thoại",
                        info: userData?.soDienThoai ?? "Chưa cập nhật",
                      ),
                      Info(
                        infoKey: "Giới tính",
                        info: _getGenderText(userData?.gioiTinh),
                      ),
                      Info(
                        infoKey: "Ngày sinh",
                        info: _formatDate(userData?.ngaySinh),
                      ),
                      Info(
                        infoKey: "Địa chỉ",
                        info: userData?.diaChi ?? "Chưa cập nhật",
                      ),
                      Info(
                        infoKey: "Bằng cấp",
                        info: userData?.bangCap ?? "Chưa cập nhật",
                      ),
                      Info(
                        infoKey: "Kinh nghiệm",
                        info: userData?.kinhNghiem ?? "Chưa cập nhật",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ======= UI components giữ nguyên phong cách gốc =======

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    required this.image,
    this.isShowPhotoUpload = false,
    this.imageUploadBtnPress,
  });

  final String image;
  final bool isShowPhotoUpload;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(image),
              backgroundColor: AppColors.primarySurface,
              onBackgroundImageError: (_, __) {},
              child: image.isEmpty 
                ? Icon(
                    Icons.person, 
                    size: 60, 
                    color: AppColors.primary,
                  ) 
                : null,
            ),
          ),
          if (isShowPhotoUpload)
            Positioned(
              bottom: 4,
              right: 4,
              child: InkWell(
                onTap: imageUploadBtnPress,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({super.key, required this.infoKey, required this.info});

  final String infoKey, info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              infoKey,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppTypography.body2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              info,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppTypography.body2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
