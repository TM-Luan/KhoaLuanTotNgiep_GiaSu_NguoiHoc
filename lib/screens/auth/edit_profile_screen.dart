import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/dropdown_repository.dart';

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
  final DropdownRepository _dropdownRepo = DropdownRepository();
  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthController;
  late TextEditingController _degreeController;
  late TextEditingController _truongDaoTaoController;
  late TextEditingController _chuyenNganhController;
  late TextEditingController _thanhTichController;

  File? _newAnhDaiDienFile;
  File? _newAnhCCCDMatTruocFile;
  File? _newAnhCCCDMatSauFile;
  File? _newAnhBangCapFile;

  bool _isLoading = false;
  DateTime? _selectedDate;

  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];
  String? _selectedGender;

  final List<String> _degreeOptions = [
    'Bằng tốt nghiệp THCS và THPT',
    'Bằng tốt nghiệp trung cấp và cao đẳng',
    'Bằng cử nhân',
    'Bằng thạc sĩ',
    'Bằng tiến sĩ',
    'Khác (Tự nhập)',
  ];
  String? _selectedDegree;
  bool _isCustomDegree = false;

  final List<String> _experienceOptions = [
    'Chưa có kinh nghiệm',
    '1 năm',
    '2 năm',
    '3 năm',
    '4 năm',
    '5 năm',
  ];
  String? _selectedExperience;

  List<DropdownItem> _allMonHoc = [];
  int? _selectedMonID;
  bool _isLoadingMonHoc = false;

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
    final currentDegree = widget.user.bangCap;
    if (currentDegree != null && _degreeOptions.contains(currentDegree)) {
      _selectedDegree = currentDegree;
      _isCustomDegree = false;
    } else if (currentDegree != null && currentDegree.isNotEmpty) {
      _selectedDegree = 'Khác (Tự nhập)';
      _isCustomDegree = true;
    } else {
      _selectedDegree = null;
      _isCustomDegree = false;
    }
    final currentExperience = widget.user.kinhNghiem;
    if (currentExperience != null &&
        _experienceOptions.contains(currentExperience)) {
      _selectedExperience = currentExperience;
    } else {
      _selectedExperience = null;
    }
    _selectedMonID = widget.user.monID;

    if (_isGiaSu) {
      _fetchMonHoc();
    }

    _birthController = TextEditingController();
    if (widget.user.ngaySinh != null && widget.user.ngaySinh!.isNotEmpty) {
      try {
        _selectedDate = DateTime.tryParse(widget.user.ngaySinh!);
        if (_selectedDate != null) {
          _birthController.text = _displayFormat.format(_selectedDate!);
        } else {
          _birthController.text = widget.user.ngaySinh!;
        }
      } catch (e) {
        _birthController.text = '';
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

  // === ⭐️ HÀM TẢI DANH SÁCH MÔN HỌC (cho Dropdown) ⭐️ ===
  Future<void> _fetchMonHoc() async {
    setState(() => _isLoadingMonHoc = true);
    try {
      final monHocList = await _dropdownRepo.getMonHocList();
      if (mounted) {
        setState(() {
          _allMonHoc = monHocList;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách môn học: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMonHoc = false);
      }
    }
  }
  // === ⭐️ KẾT THÚC HÀM ⭐️ ===

  // === ⭐️ XÓA HÀM _showMonHocDialog() ⭐️ ===
  // (Không cần nữa vì dùng Dropdown)

  // Hàm lưu hồ sơ và upload ảnh
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // === XỬ LÝ DỮ LIỆU (Bằng cấp) ===
    String? finalDegree;
    if (_isGiaSu) {
      if (_selectedDegree == 'Khác (Tự nhập)') {
        finalDegree = _degreeController.text.trim();
      } else {
        finalDegree = _selectedDegree;
      }
    } else {
      finalDegree = widget.user.bangCap;
    }

    // === XỬ LÝ DỮ LIỆU (Kinh nghiệm) ===
    String? finalExperience =
        _isGiaSu ? _selectedExperience : widget.user.kinhNghiem;

    final updatedUser = UserProfile(
      // Thông tin Text
      taiKhoanID: widget.user.taiKhoanID,
      hoTen: _nameController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      diaChi: _addressController.text.trim(),
      gioiTinh: _selectedGender,

      // Ngày sinh
      ngaySinh:
          _selectedDate != null ? _apiFormat.format(_selectedDate!) : null,

      // Thông tin Text (Gia sư)
      bangCap: finalDegree,
      kinhNghiem: finalExperience,
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

      // ⭐️ SỬA LẠI: Thêm MonID đã chọn
      monID: _selectedMonID,
      // ⭐️ XÓA: tenMon: _selectedMonHoc (vì đã sai)

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
      vaiTro: widget.user.vaiTro, // Dòng này quan trọng khi gửi đi
      trangThai: widget.user.trangThai,
      giaSuID: widget.user.giaSuID,
      nguoiHocID: widget.user.nguoiHocID,

      // Giữ lại Tên Môn (dù không gửi đi) để model được nhất quán
      tenMon: widget.user.tenMon,
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

        // === SỬA LỖI (Giữ nguyên) ===
        if (res.success) {
          UserProfile? returnedProfile = res.data;
          if (returnedProfile != null) {
            returnedProfile.vaiTro = widget.user.vaiTro;
          }
          Navigator.pop(context, returnedProfile);
        }
        // === KẾT THÚC SỬA LỖI ===
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

                // === TRƯỜNG BẰNG CẤP ===
                _buildDegreeDropdown(), // Widget Dropdown mới
                if (_isCustomDegree) // Chỉ hiển thị nếu chọn "Khác"
                  _buildField(
                    "Nhập bằng cấp khác *",
                    _degreeController,
                    maxLines: 2,
                    isRequired: true, // Bắt buộc nhập nếu đã chọn "Khác"
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
                _buildMonHocDropdown(),

                _buildExperienceDropdown(),

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
                      Image.file(newImageFile, fit: BoxFit.contain)
                    // 2. Nếu không, hiển thị link ảnh cũ
                    else if (currentImageUrl != null &&
                        currentImageUrl.isNotEmpty)
                      Image.network(
                        currentImageUrl,
                        fit: BoxFit.contain,
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
          return null; // Giới tính không bắt buộc
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
          return null; // Ngày sinh không bắt buộc
        },
      ),
    );
  }

  // === WIDGET CHO BẰNG CẤP ===
  Widget _buildDegreeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: DropdownButtonFormField<String>(
        value: _selectedDegree,
        style: TextStyle(
          fontSize: AppTypography.body1,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: "Bằng cấp",
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
            _degreeOptions.map((String degree) {
              return DropdownMenuItem<String>(
                value: degree,
                child: Text(
                  degree,
                  style: TextStyle(
                    fontSize: AppTypography.body1,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis, // Chống tràn
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDegree = newValue;
            if (newValue == 'Khác (Tự nhập)') {
              _isCustomDegree = true;
            } else {
              _isCustomDegree = false;
              _degreeController.clear(); // Xóa text tự nhập nếu đổi ý
            }
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn bằng cấp'; // Có thể đặt là optional
          }
          return null;
        },
        isExpanded: true, // Cho phép text dài hiển thị
      ),
    );
  }

  // === WIDGET CHO KINH NGHIỆM ===
  Widget _buildExperienceDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: DropdownButtonFormField<String>(
        value: _selectedExperience,
        style: TextStyle(
          fontSize: AppTypography.body1,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: "Kinh nghiệm",
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
            _experienceOptions.map((String exp) {
              return DropdownMenuItem<String>(
                value: exp,
                child: Text(
                  exp,
                  style: TextStyle(
                    fontSize: AppTypography.body1,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedExperience = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn kinh nghiệm';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMonHocDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: DropdownButtonFormField<int>(
        value: _selectedMonID, // Dùng ID
        hint: Text(_isLoadingMonHoc ? "Đang tải môn học..." : "Chọn môn học"),
        style: TextStyle(
          fontSize: AppTypography.body1,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: "Môn dạy",
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
            _allMonHoc.map((DropdownItem mon) {
              return DropdownMenuItem<int>(
                value: mon.id,
                child: Text(
                  mon.ten,
                  style: TextStyle(
                    fontSize: AppTypography.body1,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _selectedMonID = newValue;
          });
        },
        validator: (value) {
          return null;
        },
        isExpanded: true,
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
    _truongDaoTaoController.dispose();
    _chuyenNganhController.dispose();
    _thanhTichController.dispose();

    super.dispose();
  }
}

class EditProfilePic extends StatelessWidget {
  const EditProfilePic({
    super.key,
    required this.image,
    this.newImageFile,
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
              child: SizedBox(width: 110, height: 110, child: _buildImage()),
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

  Widget _buildImage() {
    if (newImageFile != null) {
      return Image.file(newImageFile!, fit: BoxFit.cover);
    }

    if (image.isNotEmpty) {
      return Image.network(
        image,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarPlaceholder();
        },

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

    return _buildAvatarPlaceholder();
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primarySurface,
      child: Icon(Icons.person, size: 50, color: AppColors.primary),
    );
  }
}
