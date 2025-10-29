// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
  late TextEditingController _genderController;
  late TextEditingController _birthController;
  late TextEditingController _degreeController;
  late TextEditingController _experienceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.hoTen ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.soDienThoai ?? '');
    _addressController = TextEditingController(text: widget.user.diaChi ?? '');
    _genderController = TextEditingController(text: widget.user.gioiTinh ?? '');
    _birthController = TextEditingController(text: widget.user.ngaySinh ?? '');
    _degreeController = TextEditingController(text: widget.user.bangCap ?? '');
    _experienceController = TextEditingController(text: widget.user.kinhNghiem ?? '');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedUser = UserProfile(
      hoTen: _nameController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      diaChi: _addressController.text.trim(),
      gioiTinh: _genderController.text.trim(),
      ngaySinh: _birthController.text.trim(),
      bangCap: _degreeController.text.trim(),
      kinhNghiem: _experienceController.text.trim(),
      anhDaiDien: widget.user.anhDaiDien,
    );

    final res = await _repo.updateProfile(updatedUser);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
      if (res.success) Navigator.pop(context, res.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        backgroundColor: const Color(0xFF00BF6D),
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
                image: widget.user.anhDaiDien ??
                    'https://i.postimg.cc/cCsYDjvj/user-2.png',
                imageUploadBtnPress: () {},
              ),
              const Divider(),
              _buildField("Họ tên", _nameController),
              _buildField("Email", _emailController, keyboard: TextInputType.emailAddress),
              _buildField("Số điện thoại", _phoneController, keyboard: TextInputType.phone),
              _buildField("Địa chỉ", _addressController),
              _buildField("Giới tính", _genderController),
              _buildField("Ngày sinh (YYYY-MM-DD)", _birthController),
              _buildField("Bằng cấp", _degreeController),
              _buildField("Kinh nghiệm", _experienceController, maxLines: 2),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BF6D),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(140, 48),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Lưu thay đổi"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (v) => (v == null || v.isEmpty) ? 'Không được bỏ trống' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFF00BF6D).withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    required this.image,
    this.imageUploadBtnPress,
  });

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
          ),
          InkWell(
            onTap: imageUploadBtnPress,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF00BF6D),
              child: Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
