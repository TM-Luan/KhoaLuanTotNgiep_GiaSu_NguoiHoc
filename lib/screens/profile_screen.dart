import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final repo = AuthRepository();
      final response = await repo.getProfile();

      if (response.success && response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
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
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userData = _userProfile;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text("Trang cá nhân"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ProfilePic(
              image:
                  userData?.anhDaiDien ??
                  "https://i.postimg.cc/cCsYDjvj/user-2.png",
            ),
            Text(
              userData?.hoTen ?? "Chưa có tên",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getRoleText(userData?.vaiTro),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const Divider(height: 32.0),

            // Thông tin cá nhân
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Thông tin cá nhân",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            Info(
              infoKey: "Mã tài khoản",
              info: userData?.taiKhoanID?.toString() ?? "N/A",
            ),
            Info(infoKey: "Email", info: userData?.email ?? "Chưa cập nhật"),
            Info(
              infoKey: "Số điện thoại",
              info: userData?.soDienThoai ?? "Chưa cập nhật",
            ),
            Info(
              infoKey: "Giới tính",
              info: _getGenderText(userData?.gioiTinh),
            ),
            Info(infoKey: "Ngày sinh", info: _formatDate(userData?.ngaySinh)),
            Info(infoKey: "Địa chỉ", info: userData?.diaChi ?? "Chưa cập nhật"),

            // Thông tin học vấn (nếu là gia sư)
            if (userData?.vaiTro == 2) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Thông tin học vấn",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Info(
                infoKey: "Bằng cấp",
                info: userData?.bangCap ?? "Chưa cập nhật",
              ),
              Info(
                infoKey: "Kinh nghiệm",
                info: userData?.kinhNghiem ?? "Chưa cập nhật",
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(
            context,
          ).textTheme.bodyLarge!.color!.withOpacity(0.08),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(image),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback nếu ảnh lỗi
              return;
            },
            child: image.isEmpty ? const Icon(Icons.person, size: 50) : null,
          ),
          if (isShowPhotoUpload)
            InkWell(
              onTap: imageUploadBtnPress,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              infoKey,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge!.color!.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              info,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
