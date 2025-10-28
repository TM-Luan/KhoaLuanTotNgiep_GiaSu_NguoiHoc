import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00BF6D),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00BF6D),
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
            backgroundColor: res.success ? AppColors.primaryBlue : Colors.red,
          ),
        );
        if (res.success) Navigator.pop(context, res.data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Thông tin gia sư",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text("Hủy"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(140, 48),
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
                              style: TextStyle(color: Colors.white),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (v) {
          if (isRequired && (v == null || v.isEmpty)) {
            return 'Trường này là bắt buộc';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFF00BF6D).withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: "Giới tính",
          filled: true,
          fillColor: const Color(0xFF00BF6D).withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        // SỬA LẠI: Sử dụng List<String> đơn giản
        items:
            _genderOptions.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _birthController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: "Ngày sinh",
          filled: true,
          fillColor: const Color(0xFF00BF6D).withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: AppColors.primaryBlue,
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
