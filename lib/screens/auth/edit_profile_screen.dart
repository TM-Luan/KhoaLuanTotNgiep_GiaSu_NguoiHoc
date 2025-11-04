// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AuthRepository();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthController;
  late TextEditingController _degreeController;
  late TextEditingController _experienceController;

  bool _isLoading = false;
  DateTime? _selectedDate;

  // SỬA LẠI: Sử dụng List<String> đơn giản
  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.hoTen ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(
      text: widget.user.soDienThoai ?? '',
    );
    _addressController = TextEditingController(text: widget.user.diaChi ?? '');
    _degreeController = TextEditingController(text: widget.user.bangCap ?? '');
    _experienceController = TextEditingController(
      text: widget.user.kinhNghiem ?? '',
    );

    // Xử lý giới tính - giữ nguyên giá trị từ API nếu có
    _selectedGender = widget.user.gioiTinh;

    // Nếu giá trị từ API không có trong options, set về null
    if (_selectedGender != null && !_genderOptions.contains(_selectedGender)) {
      _selectedGender = null;
    }

    // Xử lý ngày sinh
    if (widget.user.ngaySinh != null && widget.user.ngaySinh!.isNotEmpty) {
      try {
        final parts = widget.user.ngaySinh!.split('-');
        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          _birthController = TextEditingController(text: widget.user.ngaySinh);
        } else {
          _birthController = TextEditingController();
        }
      } catch (e) {
        _birthController = TextEditingController();
      }
    } else {
      _birthController = TextEditingController();
    }
  }

  // Kiểm tra xem người dùng có phải là gia sư không
  bool get _isGiaSu => widget.user.vaiTro == 2;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedUser = UserProfile(
      taiKhoanID: widget.user.taiKhoanID,
      hoTen: _nameController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      diaChi: _addressController.text.trim(),
      gioiTinh: _selectedGender, // Gửi string trực tiếp ("Nam", "Nữ", "Khác")
      ngaySinh: _birthController.text.trim(),
      // Chỉ cập nhật bằng cấp và kinh nghiệm nếu là gia sư
      bangCap: _isGiaSu ? _degreeController.text.trim() : widget.user.bangCap,
      kinhNghiem:
          _isGiaSu ? _experienceController.text.trim() : widget.user.kinhNghiem,
      anhDaiDien: widget.user.anhDaiDien,
      vaiTro: widget.user.vaiTro,
    );

    try {
      final res = await _repo.updateProfile(updatedUser);
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: res.success ? AppColors.success : AppColors.error,
          ),
        );
        if (res.success) Navigator.pop(context, res.data);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chỉnh sửa hồ sơ",
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProfilePic(
                image:
                    widget.user.anhDaiDien ??
                    'https://i.postimg.cc/cCsYDjvj/user-2.png',
                imageUploadBtnPress: () {
                  // TODO: Thêm chức năng upload ảnh
                },
              ),
              const Divider(),

              // Thông tin cơ bản cho tất cả vai trò
              _buildField("Họ tên *", _nameController),
              _buildField(
                "Email *",
                _emailController,
                keyboard: TextInputType.emailAddress,
              ),
              _buildField(
                "Số điện thoại *",
                _phoneController,
                keyboard: TextInputType.phone,
              ),
              _buildField("Địa chỉ", _addressController),

              // Dropdown cho giới tính - SỬA LẠI: Sử dụng List<String>
              _buildGenderDropdown(),

              // Date picker cho ngày sinh
              _buildDateField(),

              // Chỉ hiển thị bằng cấp và kinh nghiệm cho gia sư
              if (_isGiaSu) ...[
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Thông tin gia sư",
                    style: TextStyle(
                      fontSize: AppTypography.heading3,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildField(
                  "Bằng cấp",
                  _degreeController,
                  maxLines: 2,
                  isRequired: false,
                ),
                _buildField(
                  "Kinh nghiệm",
                  _experienceController,
                  maxLines: 3,
                  isRequired: false,
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      "Hủy",
                      style: TextStyle(fontSize: AppTypography.body1),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
                      ),
                      minimumSize: const Size(140, 48),
                    ),
                    child:
                      _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.textLight,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Lưu thay đổi",
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: AppTypography.body1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: AppTypography.body1,
          color: AppColors.textPrimary,
        ),
        validator: (v) {
          if (isRequired && (v == null || v.isEmpty)) {
            return 'Trường này là bắt buộc';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppTypography.body2,
          ),
          filled: true,
          fillColor: AppColors.primarySurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius * 4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius * 4),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 2),
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius * 4),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        style: TextStyle(
          fontSize: AppTypography.body1,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: "Giới tính",
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppTypography.body2,
          ),
          filled: true,
          fillColor: AppColors.primarySurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius * 4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius * 4),
          ),
        ),
        // SỬA LẠI: Sử dụng List<String> đơn giản
        items: _genderOptions.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(
              gender,
              style: TextStyle(
                fontSize: AppTypography.body1,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) {
          // Không bắt buộc chọn giới tính
          return null;
        },
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: TextFormField(
        controller: _birthController,
        readOnly: true,
        onTap: () => _selectDate(context),
        style: TextStyle(
          fontSize: AppTypography.body1,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: "Ngày sinh",
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppTypography.body2,
          ),
          filled: true,
          fillColor: AppColors.primarySurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius * 4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius * 4),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: AppSpacing.iconSize,
            ),
            onPressed: () => _selectDate(context),
          ),
        ),
        validator: (value) {
          // Không bắt buộc nhập ngày sinh
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthController.dispose();
    _degreeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key, required this.image, this.imageUploadBtnPress});

  final String image;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundImage: NetworkImage(image),
            onBackgroundImageError: (_, __) {},
            child: image.isEmpty ? const Icon(Icons.person, size: 50) : null,
          ),
          InkWell(
            onTap: imageUploadBtnPress,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
