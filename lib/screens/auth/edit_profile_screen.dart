import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/dropdown_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Thêm thư viện này để vẽ viền nét đứt cho đẹp (nếu chưa có thì dùng border thường)
// Nếu không muốn cài thêm package, mình sẽ dùng border solid nét nhạt.

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

  // --- UI Constants ---
  final Color _bgColor = const Color(0xFFF8F9FA); // Xám nhạt hiện đại
  final Color _cardColor = Colors.white;
  final Color _borderColor = const Color(0xFFE9ECEF);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);

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
              onPrimary: Colors.white,
              onSurface: _textPrimary,
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

  Future<void> _pickImage(Function(File?) onImagePicked) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    } else {
      onImagePicked(null);
    }
  }

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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

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

    String? finalExperience =
        _isGiaSu ? _selectedExperience : widget.user.kinhNghiem;

    final updatedUser = UserProfile(
      taiKhoanID: widget.user.taiKhoanID,
      hoTen: _nameController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      diaChi: _addressController.text.trim(),
      gioiTinh: _selectedGender,
      ngaySinh:
          _selectedDate != null ? _apiFormat.format(_selectedDate!) : null,
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
      monID: _selectedMonID,
      newAnhDaiDienFile: _newAnhDaiDienFile,
      newAnhCCCDMatTruocFile: _newAnhCCCDMatTruocFile,
      newAnhCCCDMatSauFile: _newAnhCCCDMatSauFile,
      newAnhBangCapFile: _newAnhBangCapFile,
      anhDaiDien: widget.user.anhDaiDien,
      anhCCCDMatTruoc: widget.user.anhCCCDMatTruoc,
      anhCCCDMatSau: widget.user.anhCCCDMatSau,
      anhBangCap: widget.user.anhBangCap,
      vaiTro: widget.user.vaiTro,
      trangThai: widget.user.trangThai,
      giaSuID: widget.user.giaSuID,
      nguoiHocID: widget.user.nguoiHocID,
      tenMon: widget.user.tenMon,
    );

    try {
      final res = await _repo.updateProfile(updatedUser);
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: res.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (res.success) {
          UserProfile? returnedProfile = res.data;
          if (returnedProfile != null) {
            returnedProfile.vaiTro = widget.user.vaiTro;
          }
          Navigator.pop(context, returnedProfile);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ================= UI BUILDER =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa hồ sơ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Avatar Section ---
              Center(
                child: EditProfilePic(
                  image: widget.user.anhDaiDien ?? '',
                  newImageFile: _newAnhDaiDienFile,
                  imageUploadBtnPress:
                      () => _pickImage((file) {
                        if (file != null) {
                          setState(() => _newAnhDaiDienFile = file);
                        }
                      }),
                ),
              ),
              const SizedBox(height: 24),

              // --- Personal Info Section ---
              _buildSectionContainer(
                title: "Thông tin cá nhân",
                children: [
                  _buildField("Họ và tên *", _nameController),
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
                  Row(
                    children: [
                      Expanded(child: _buildGenderDropdown()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDateField()),
                    ],
                  ),
                ],
              ),

              // --- Tutor Info Section ---
              if (_isGiaSu) ...[
                const SizedBox(height: 20),
                _buildSectionContainer(
                  title: "Thông tin gia sư",
                  children: [
                    _buildDegreeDropdown(),
                    if (_isCustomDegree)
                      _buildField(
                        "Chi tiết bằng cấp *",
                        _degreeController,
                        isRequired: true,
                      ),
                    _buildField(
                      "Trường đào tạo",
                      _truongDaoTaoController,
                      isRequired: false,
                    ),
                    _buildField(
                      "Chuyên ngành",
                      _chuyenNganhController,
                      isRequired: false,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMonHocDropdown()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildExperienceDropdown()),
                      ],
                    ),
                    _buildField(
                      "Thành tích nổi bật",
                      _thanhTichController,
                      maxLines: 3,
                      isRequired: false,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildSectionContainer(
                  title: "Hồ sơ xác thực",
                  children: [
                    _buildImageUploadBlock(
                      "Ảnh CCCD Mặt trước",
                      widget.user.anhCCCDMatTruoc,
                      _newAnhCCCDMatTruocFile,
                      () => _pickImage(
                        (f) => setState(() => _newAnhCCCDMatTruocFile = f),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildImageUploadBlock(
                      "Ảnh CCCD Mặt sau",
                      widget.user.anhCCCDMatSau,
                      _newAnhCCCDMatSauFile,
                      () => _pickImage(
                        (f) => setState(() => _newAnhCCCDMatSauFile = f),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildImageUploadBlock(
                      "Ảnh Bằng cấp / Chứng chỉ",
                      widget.user.anhBangCap,
                      _newAnhBangCapFile,
                      () => _pickImage(
                        (f) => setState(() => _newAnhBangCapFile = f),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
              _buildBottomActions(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // --- Modern Input Styles ---

  InputDecoration _cleanInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textSecondary, fontSize: 14),
      floatingLabelStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: TextStyle(fontSize: 15, color: _textPrimary),
        validator:
            (v) =>
                (isRequired && (v == null || v.isEmpty))
                    ? 'Không được để trống'
                    : null,
        decoration: _cleanInputDecoration(label),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        style: TextStyle(fontSize: 15, color: _textPrimary),
        decoration: _cleanInputDecoration("Giới tính"),
        items:
            _genderOptions
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
        onChanged: (v) => setState(() => _selectedGender = v),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _birthController,
        readOnly: true,
        onTap: () => _selectDate(context),
        style: TextStyle(fontSize: 15, color: _textPrimary),
        decoration: _cleanInputDecoration("Ngày sinh").copyWith(
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: _textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDegreeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedDegree,
        isExpanded: true,
        style: TextStyle(fontSize: 15, color: _textPrimary),
        decoration: _cleanInputDecoration("Bằng cấp"),
        items:
            _degreeOptions
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(d, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (v) {
          setState(() {
            _selectedDegree = v;
            _isCustomDegree = (v == 'Khác (Tự nhập)');
            if (!_isCustomDegree) _degreeController.clear();
          });
        },
      ),
    );
  }

  Widget _buildExperienceDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedExperience,
        isExpanded: true,
        style: TextStyle(fontSize: 15, color: _textPrimary),
        decoration: _cleanInputDecoration("Kinh nghiệm"),
        items:
            _experienceOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (v) => setState(() => _selectedExperience = v),
        validator: (v) => (v == null) ? 'Chọn kinh nghiệm' : null,
      ),
    );
  }

  Widget _buildMonHocDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: _selectedMonID,
        isExpanded: true,
        style: TextStyle(fontSize: 15, color: _textPrimary),
        decoration: _cleanInputDecoration("Môn dạy"),
        hint: Text(_isLoadingMonHoc ? "Đang tải..." : "Chọn môn"),
        items:
            _allMonHoc
                .map(
                  (m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.ten, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (v) => setState(() => _selectedMonID = v),
      ),
    );
  }

  // --- Modern Image Upload Block ---
  Widget _buildImageUploadBlock(
    String title,
    String? url,
    File? file,
    VoidCallback onTap,
  ) {
    bool hasImage = file != null || (url != null && url.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage ? Colors.transparent : _borderColor,
                width: 1.5,
                // Nếu muốn nét đứt thì dùng package dotted_border, ở đây dùng nét liền nhạt cho đơn giản nhưng clean
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (file != null)
                    Image.file(file, fit: BoxFit.cover)
                  else if (url != null && url.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _buildUploadPlaceholder(),
                    )
                  else
                    _buildUploadPlaceholder(),

                  // Edit Overlay
                  if (hasImage)
                    Container(
                      color: Colors.black26,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 32,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          "Nhấn để tải ảnh lên",
          style: TextStyle(color: _textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: _textPrimary,
            ),
            child: const Text("Hủy bỏ"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      "Lưu thay đổi",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
          ),
        ),
      ],
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

// --- Avatar Widget Refined ---
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
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFEEEEEE),
            child: ClipOval(
              child: SizedBox(width: 120, height: 120, child: _buildImage()),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: imageUploadBtnPress,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (newImageFile != null) {
      return Image.file(newImageFile!, fit: BoxFit.cover);
    }
    if (image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        memCacheWidth: 400,
        placeholder:
            (context, url) =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
      );
    }
    return _buildAvatarPlaceholder();
  }

  Widget _buildAvatarPlaceholder() {
    return const Icon(Icons.person, size: 50, color: Colors.grey);
  }
}
