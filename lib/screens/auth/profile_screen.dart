import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/auth/edit_profile_screen.dart';

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

  String _formatDateString(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "Chưa cập nhật";
    }
    try {
      DateTime parsedDate;
      if (dateString.contains('-') && dateString.startsWith('20')) {
        parsedDate = DateTime.parse(dateString);
      } else {
        parsedDate = DateFormat('dd/MM/yyyy').parse(dateString);
      }
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return dateString;
    }
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
          backgroundColor: Colors.white, // Nền trắng sạch
          appBar: AppBar(
            title: const Text(
              "Hồ sơ cá nhân",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            actions: [
              if (state is AuthAuthenticated)
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditProfileScreen(user: userData!),
                      ),
                    ).then((result) {
                      if (result != null) {
                        context.read<AuthBloc>().add(
                          const FetchProfileRequested(),
                        );
                      }
                    });
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // --- Header: Avatar & Name ---
                Center(
                  child: Column(
                    children: [
                      ProfilePic(image: userData?.anhDaiDien ?? ""),
                      const SizedBox(height: 16),
                      Text(
                        userData?.hoTen ?? "Chưa cập nhật",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleText(userData?.vaiTro),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- Sections ---
                _buildSectionTitle("Thông tin liên hệ"),
                _buildInfoTile("Email", userData?.email, Icons.email_outlined),
                _buildInfoTile(
                  "Điện thoại",
                  userData?.soDienThoai,
                  Icons.phone_outlined,
                ),
                _buildInfoTile(
                  "Địa chỉ",
                  userData?.diaChi,
                  Icons.location_on_outlined,
                ),
                _buildInfoTile(
                  "Giới tính",
                  userData?.gioiTinh,
                  Icons.person_outline,
                ),
                _buildInfoTile(
                  "Ngày sinh",
                  _formatDateString(userData?.ngaySinh),
                  Icons.cake_outlined,
                ),

                if (isGiaSu) ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle("Hồ sơ gia sư"),
                  _buildInfoTile(
                    "Môn dạy",
                    userData?.tenMon,
                    Icons.book_outlined,
                  ), // Sửa lại key hiển thị
                  _buildInfoTile(
                    "Bằng cấp",
                    userData?.bangCap,
                    Icons.school_outlined,
                  ),
                  _buildInfoTile(
                    "Trường ĐT",
                    userData?.truongDaoTao,
                    Icons.business_outlined,
                  ),
                  _buildInfoTile(
                    "Chuyên ngành",
                    userData?.chuyenNganh,
                    Icons.work_outline,
                  ),
                  _buildInfoTile(
                    "Kinh nghiệm",
                    userData?.kinhNghiem,
                    Icons.history_edu_outlined,
                  ),
                  _buildInfoTile(
                    "Thành tích",
                    userData?.thanhTich,
                    Icons.star_outline,
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Giấy tờ xác thực"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildImagePreview(
                          "CCCD Mặt trước",
                          userData?.anhCCCDMatTruoc,
                        ),
                        const SizedBox(height: 12),
                        _buildImagePreview(
                          "CCCD Mặt sau",
                          userData?.anhCCCDMatSau,
                        ),
                        const SizedBox(height: 12),
                        _buildImagePreview(
                          "Bằng cấp / Chứng chỉ",
                          userData?.anhBangCap,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  (value == null || value.isEmpty) ? "Chưa cập nhật" : value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String title, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child:
              (url != null && url.isNotEmpty)
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                    ),
                  )
                  : Center(
                    child: Text(
                      "Chưa có ảnh",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
        ),
      ],
    );
  }
}

class ProfilePic extends StatelessWidget {
  final String image;
  const ProfilePic({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey.shade100,
        backgroundImage: (image.isNotEmpty) ? NetworkImage(image) : null,
        child:
            (image.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
      ),
    );
  }
}
