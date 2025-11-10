import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:intl/intl.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
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
    if (gioiTinh == null || gioiTinh.isEmpty) {
      return "Chưa cập nhật";
    }
    return gioiTinh;
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

        final bool isGiaSu = userData?.vaiTro == 2;

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            title: Text(
              "Trang cá nhân",
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
                    borderRadius: BorderRadius.circular(
                      AppSpacing.cardBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProfilePic(image: userData?.anhDaiDien ?? ""),
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
                          borderRadius: BorderRadius.circular(
                            AppSpacing.buttonBorderRadius,
                          ),
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
                    borderRadius: BorderRadius.circular(
                      AppSpacing.cardBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                              borderRadius: BorderRadius.circular(
                                AppSpacing.iconContainerRadius,
                              ),
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
                        info:
                            userData?.taiKhoanID?.toString() ?? "Chưa cập nhật",
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

                      // ⭐️ CHỈ HIỂN THỊ NẾU LÀ GIA SƯ
                      if (isGiaSu) ...[
                        Info(
                          infoKey: "Bằng cấp",
                          info: userData?.bangCap ?? "Chưa cập nhật",
                        ),
                        Info(
                          infoKey: "Trường đào tạo",
                          info: userData?.truongDaoTao ?? "Chưa cập nhật",
                        ),
                        Info(
                          infoKey: "Chuyên ngành",
                          info: userData?.chuyenNganh ?? "Chưa cập nhật",
                        ),
                        Info(
                          infoKey: "Kinh nghiệm",
                          info: userData?.kinhNghiem ?? "Chưa cập nhật",
                        ),
                        Info(
                          infoKey: "Thành tích",
                          info: userData?.thanhTich ?? "Chưa cập nhật",
                        ),

                        // ⭐️ SỬA LẠI: Hiển thị ảnh thay vì text
                        ProfileImageInfo(
                          title: "CCCD mặt trước",
                          imageUrl: userData?.anhCCCDMatTruoc,
                        ),
                        ProfileImageInfo(
                          title: "CCCD mặt sau",
                          imageUrl: userData?.anhCCCDMatSau,
                        ),
                        ProfileImageInfo(
                          title: "Ảnh bằng cấp",
                          imageUrl: userData?.anhBangCap,
                        ),
                      ],
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

// ======= UI components (Giữ nguyên) =======

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
            color: AppColors.primary.withOpacity(0.2),
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
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primarySurface,
              child: ClipOval(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: _buildImage(image), // Gọi helper
                ),
              ),
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
                        color: Colors.black.withOpacity(0.2),
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

  // Helper build ảnh cho Ảnh đại diện
  Widget _buildImage(String image) {
    if (image.isNotEmpty) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
    // Không có ảnh nào -> Placeholder
    return _buildAvatarPlaceholder();
  }

  // Placeholder cho ảnh đại diện
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primarySurface,
      child: Icon(Icons.person, size: 50, color: AppColors.primary),
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
        border: Border.all(color: AppColors.borderLight, width: 1),
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

// ⭐️ WIDGET MỚI ĐỂ HIỂN THỊ ẢNH
class ProfileImageInfo extends StatelessWidget {
  final String title;
  final String? imageUrl;

  const ProfileImageInfo({super.key, required this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppTypography.body2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Khung hiển thị ảnh
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background, // Nền trắng
              borderRadius: BorderRadius.circular(
                AppSpacing.buttonBorderRadius,
              ),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppSpacing.buttonBorderRadius,
              ),
              child: _buildImage(), // Gọi helper
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder("Lỗi tải ảnh");
        },
      );
    } else {
      return _buildPlaceholder("Chưa cập nhật ảnh");
    }
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textSecondary,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppTypography.body2,
            ),
          ),
        ],
      ),
    );
  }
}
