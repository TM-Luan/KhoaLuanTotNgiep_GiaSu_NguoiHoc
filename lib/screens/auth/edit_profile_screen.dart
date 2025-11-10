// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // <-- Đã thêm
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
  final ImagePicker _picker = ImagePicker();

  // ⭐️ Thêm 2 trình định dạng ngày
  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  // Thông tin chung
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController
  _birthController; // Sẽ được kiểm soát bởi _displayFormat

  // Thông tin Gia Sư
  late TextEditingController _degreeController;
  late TextEditingController _experienceController;
  late TextEditingController _truongDaoTaoController;
  late TextEditingController _chuyenNganhController;
  late TextEditingController _thanhTichController;

  // Các biến File để lưu ảnh mới được chọn
  File? _newAnhDaiDienFile;
  File? _newAnhCCCDMatTruocFile;
  File? _newAnhCCCDMatSauFile;
  File? _newAnhBangCapFile;

  bool _isLoading = false;
  DateTime? _selectedDate; // Biến lưu ngày đã chọn

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
    _truongDaoTaoController = TextEditingController(
      text: widget.user.truongDaoTao ?? '',
    );
    _chuyenNganhController = TextEditingController(
      text: widget.user.chuyenNganh ?? '',
    );
    _thanhTichController = TextEditingController(
      text: widget.user.thanhTich ?? '',
    );

    _selectedGender = widget.user.gioiTinh;
    if (_selectedGender != null && !_genderOptions.contains(_selectedGender)) {
      _selectedGender = null;
    }

    // ⭐️ Sửa lỗi format ngày ở đây
    _birthController = TextEditingController(); // Khởi tạo rỗng
    if (widget.user.ngaySinh != null && widget.user.ngaySinh!.isNotEmpty) {
      try {
        // Vẫn parse ngày từ server (chuẩn YYYY-MM-DD)
        _selectedDate = DateTime.tryParse(widget.user.ngaySinh!);
        if (_selectedDate != null) {
          // Nhưng hiển thị ra bằng format "dd/MM/yyyy" cho đẹp
          _birthController.text = _displayFormat.format(_selectedDate!);
        } else {
          // Nếu server trả về định dạng lạ, hiển thị tạm
          _birthController.text = widget.user.ngaySinh!;
        }
      } catch (e) {
        _birthController.text = ''; // Lỗi thì để trống
      }
    }
  }

  bool get _isGiaSu => widget.user.vaiTro == 2;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // Phần "làm đẹp" (Theme) của bạn đã TỐT, giữ nguyên
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // ⭐️ HIỂN THỊ NGÀY ĐÃ CHỌN THEO FORMAT "dd/MM/yyyy"
        _birthController.text = _displayFormat.format(picked);
      });
    }
  }

  // Hàm chọn ảnh chung
  Future<void> _pickImage(Function(File?) onImagePicked) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    } else {
      onImagePicked(null);
    }
  }

  // Hàm lưu hồ sơ và upload ảnh
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedUser = UserProfile(
      // Thông tin Text
      taiKhoanID: widget.user.taiKhoanID,
      hoTen: _nameController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      diaChi: _addressController.text.trim(),
      gioiTinh: _selectedGender,

      // ⭐️ GỬI NGÀY ĐÚNG CHUẨN API (YYYY-MM-DD)
      ngaySinh:
          _selectedDate != null ? _apiFormat.format(_selectedDate!) : null,

      // Thông tin Text (Gia sư)
      bangCap: _isGiaSu ? _degreeController.text.trim() : widget.user.bangCap,
      kinhNghiem:
          _isGiaSu ? _experienceController.text.trim() : widget.user.kinhNghiem,
      truongDaoTao:
          _isGiaSu
              ? _truongDaoTaoController.text.trim()
              : widget.user.truongDaoTao,
      chuyenNganh:
          _isGiaSu
              ? _chuyenNganhController.text.trim()
              : widget.user.chuyenNganh,
      thanhTich:
          _isGiaSu ? _thanhTichController.text.trim() : widget.user.thanhTich,

      // Thông tin File (Ảnh mới)
      newAnhDaiDienFile: _newAnhDaiDienFile,
      newAnhCCCDMatTruocFile: _newAnhCCCDMatTruocFile,
      newAnhCCCDMatSauFile: _newAnhCCCDMatSauFile,
      newAnhBangCapFile: _newAnhBangCapFile,

      // Giữ nguyên các giá trị cũ
      anhDaiDien: widget.user.anhDaiDien,
      anhCCCDMatTruoc: widget.user.anhCCCDMatTruoc,
      anhCCCDMatSau: widget.user.anhCCCDMatSau,
      anhBangCap: widget.user.anhBangCap,
      vaiTro: widget.user.vaiTro,
      trangThai: widget.user.trangThai,
      giaSuID: widget.user.giaSuID,
      nguoiHocID: widget.user.nguoiHocID,
    );

    try {
      // GỌI HÀM REPO
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
              // Ảnh đại diện
              EditProfilePic(
                image: widget.user.anhDaiDien ?? '', // Link ảnh cũ
                newImageFile: _newAnhDaiDienFile, // File ảnh mới chọn
                imageUploadBtnPress:
                    () => _pickImage((file) {
                      if (file != null) {
                        setState(() => _newAnhDaiDienFile = file);
                      }
                    }),
              ),
              const Divider(),

              // Thông tin cơ bản
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
              _buildField("Địa chỉ", _addressController, isRequired: false),
              _buildGenderDropdown(),
              _buildDateField(), // Đã sửa
              // Thông tin gia sư
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
                  "Trường đào tạo",
                  _truongDaoTaoController,
                  maxLines: 2,
                  isRequired: false,
                ),
                _buildField(
                  "Chuyên ngành",
                  _chuyenNganhController,
                  maxLines: 2,
                  isRequired: false,
                ),
                _buildField(
                  "Kinh nghiệm",
                  _experienceController,
                  maxLines: 3,
                  isRequired: false,
                ),
                _buildField(
                  "Thành tích",
                  _thanhTichController,
                  maxLines: 3,
                  isRequired: false,
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Giấy tờ & Chứng chỉ",
                    style: TextStyle(
                      fontSize: AppTypography.heading3,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Ảnh CCCD mặt trước
                _buildImageUploadField(
                  title: "Ảnh CCCD mặt trước",
                  currentImageUrl: widget.user.anhCCCDMatTruoc,
                  newImageFile: _newAnhCCCDMatTruocFile,
                  onPickImage:
                      () => _pickImage((file) {
                        if (file != null) {
                          setState(() => _newAnhCCCDMatTruocFile = file);
                        }
                      }),
                ),
                // Ảnh CCCD mặt sau
                _buildImageUploadField(
                  title: "Ảnh CCCD mặt sau",
                  currentImageUrl: widget.user.anhCCCDMatSau,
                  newImageFile: _newAnhCCCDMatSauFile,
                  onPickImage:
                      () => _pickImage((file) {
                        if (file != null) {
                          setState(() => _newAnhCCCDMatSauFile = file);
                        }
                      }),
                ),
                // Ảnh bằng cấp
                _buildImageUploadField(
                  title: "Ảnh bằng cấp",
                  currentImageUrl: widget.user.anhBangCap,
                  newImageFile: _newAnhBangCapFile,
                  onPickImage:
                      () => _pickImage((file) {
                        if (file != null) {
                          setState(() => _newAnhBangCapFile = file);
                        }
                      }),
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
                        borderRadius: BorderRadius.circular(
                          AppSpacing.buttonBorderRadius,
                        ),
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

  // Widget chung để hiển thị/chọn ảnh
  Widget _buildImageUploadField({
    required String title,
    String? currentImageUrl,
    File? newImageFile,
    required VoidCallback onPickImage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.body1,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: InkWell(
              onTap: onPickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppSpacing.cardBorderRadius,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Logic hiển thị ảnh:
                    // 1. Ưu tiên File mới
                    if (newImageFile != null)
                      Image.file(
                        newImageFile,
                        fit: BoxFit.contain, // <--- SỬA THÀNH CONTAIN
                      )
                    // 2. Nếu không, hiển thị link ảnh cũ
                    else if (currentImageUrl != null &&
                        currentImageUrl.isNotEmpty)
                      Image.network(
                        currentImageUrl,
                        fit: BoxFit.contain, // <--- SỬA THÀNH CONTAIN
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                      )
                    // 3. Nếu không có cả 2, hiển thị placeholder
                    else
                      _buildImagePlaceholder(),

                    // Nút bấm
                    Positioned(
                      bottom: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          (newImageFile != null ||
                                  (currentImageUrl != null &&
                                      currentImageUrl.isNotEmpty))
                              ? Icons.edit
                              : Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget placeholder (dùng chung cho CCCD, Bằng cấp)
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primarySurface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text("Chọn ảnh", style: TextStyle(color: AppColors.primary)),
          ],
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
            borderRadius: BorderRadius.circular(
              AppSpacing.cardBorderRadius * 4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(
              AppSpacing.cardBorderRadius * 4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 2),
            borderRadius: BorderRadius.circular(
              AppSpacing.cardBorderRadius * 4,
            ),
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
            borderRadius: BorderRadius.circular(
              AppSpacing.cardBorderRadius * 4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(
              AppSpacing.cardBorderRadius * 4,
            ),
          ),
        ),
        items:
            _genderOptions.map((String gender) {
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
            borderRadius: BorderRadius.circular(
              AppSpacing.cardBorderRadius * 4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(
              AppSpacing.cardBorderRadius * 4,
            ),
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
    _truongDaoTaoController.dispose();
    _chuyenNganhController.dispose();
    _thanhTichController.dispose();

    super.dispose();
  }
}

// UI Component cho ảnh đại diện (Đã hoàn thiện)
class EditProfilePic extends StatelessWidget {
  const EditProfilePic({
    super.key,
    required this.image, // Link ảnh cũ
    this.newImageFile, // File ảnh mới chọn
    this.imageUploadBtnPress,
  });

  final String image;
  final File? newImageFile;
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
            backgroundColor: AppColors.primarySurface,
            child: ClipOval(
              child: SizedBox(
                width: 110, // 55 * 2
                height: 110,
                child: _buildImage(), // Gọi hàm helper để hiển thị ảnh
              ),
            ),
          ),
          InkWell(
            onTap: imageUploadBtnPress,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Helper build ảnh cho Ảnh đại diện
  Widget _buildImage() {
    // 1. Ưu tiên file mới
    if (newImageFile != null) {
      return Image.file(
        newImageFile!,
        fit: BoxFit.contain, // <--- SỬA THÀNH CONTAIN
      );
    }
    // 2. Ảnh cũ từ network
    if (image.isNotEmpty) {
      return Image.network(
        image,
        fit: BoxFit.cover, // <--- SỬA THÀNH CONTAIN
        // Xử lý lỗi (hiển thị placeholder)
        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarPlaceholder();
        },
        // Hiển thị loading
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
      );
    }
    // 4. Không có ảnh nào -> Placeholder
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
