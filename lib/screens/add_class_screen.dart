import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/dropdown_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _lopHocRepo = LopHocRepository();
  final _dropdownRepo = DropdownRepository();
  final _authRepo = AuthRepository();

  bool _isSubmitting = false;
  bool _isDropdownLoading = true;
  String? _dropdownError;

  // Controllers cho các ô Text
  final _hinhThucController = TextEditingController();
  final _hocPhiController = TextEditingController();
  final _thoiLuongController = TextEditingController();
  final _soLuongController = TextEditingController(text: '1');
  final _moTaController = TextEditingController();

  // Biến lưu giá trị cho các ô Dropdown
  int? _selectedMonID;
  int? _selectedKhoiLopID;
  int? _selectedDoiTuongID;
  int? _selectedThoiGianDayID;

  // Danh sách dữ liệu thật từ API
  List<DropdownItem> _monHocList = [];
  List<DropdownItem> _khoiLopList = [];
  List<DropdownItem> _doiTuongList = [];
  List<DropdownItem> _thoiGianDayList = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  // === HÀM MỚI: Lấy NguoiHocID từ Profile API ===
  Future<int?> _getNguoiHocIDFromProfile() async {
    try {
      final ApiResponse<UserProfile> response = await _authRepo.getProfile();

      if (response.success && response.data != null) {
        final UserProfile user = response.data!;

        // Kiểm tra vai trò Người học
        if (user.vaiTro == 3) {
          if (user.nguoiHocID != null) {
            return user.nguoiHocID; // ← Dùng NguoiHocID thật
          } else {
            throw Exception('Tài khoản không có thông tin Người học');
          }
        } else {
          throw Exception('Chỉ tài khoản Người học mới được tạo lớp');
        }
      } else {
        throw Exception('Không thể lấy thông tin profile: ${response.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final responses = await Future.wait([
        _dropdownRepo.getMonHocList(),
        _dropdownRepo.getKhoiLopList(),
        _dropdownRepo.getDoiTuongList(),
        _dropdownRepo.getThoiGianDayList(),
      ]);

      if (!mounted) return;

      setState(() {
        _monHocList = responses[0];
        _khoiLopList = responses[1];
        _doiTuongList = responses[2];
        _thoiGianDayList = responses[3];
        _isDropdownLoading = false;
      });
    } catch (e) {
      setState(() {
        _dropdownError = 'Lỗi khi tải dữ liệu: $e';
        _isDropdownLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _hinhThucController.dispose();
    _hocPhiController.dispose();
    _thoiLuongController.dispose();
    _soLuongController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // --- LẤY NguoiHocID TỪ PROFILE API ---
      final int? currentNguoiHocID = await _getNguoiHocIDFromProfile();

      if (currentNguoiHocID == null) {
        throw Exception(
          'Không tìm thấy thông tin người học. Vui lòng đăng nhập lại.',
        );
      }

      // Tạo dữ liệu để gửi đi - DÙNG NguoiHocID
      Map<String, dynamic> lopHocData = {
        'NguoiHocID': currentNguoiHocID, // ← DÙNG NguoiHocID THẬT
        'HinhThuc': _hinhThucController.text,
        'HocPhi': double.tryParse(_hocPhiController.text) ?? 0,
        'ThoiLuong': _thoiLuongController.text,
        'SoLuong': int.tryParse(_soLuongController.text) ?? 1,
        'MoTa': _moTaController.text,
        'MonID': _selectedMonID,
        'KhoiLopID': _selectedKhoiLopID,
        'DoiTuongID': _selectedDoiTuongID,
        'ThoiGianDayID': _selectedThoiGianDayID,
      };

      // Gọi API tạo lớp
      final ApiResponse<LopHoc> response = await _lopHocRepo.createLopHoc(
        lopHocData,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo lớp học mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Lớp Học Mới'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isDropdownLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dropdownError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_dropdownError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadDropdownData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_isSubmitting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tạo lớp...'),
          ],
        ),
      );
    }

    return _buildForm();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Vui lòng điền thông tin lớp học bạn muốn tạo',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            _buildDropdown(
              value: _selectedMonID,
              hint: 'Chọn Môn Học',
              icon: Icons.book_outlined,
              items: _monHocList,
              onChanged: (value) {
                setState(() {
                  _selectedMonID = value;
                });
              },
            ),
            _buildDropdown(
              value: _selectedKhoiLopID,
              hint: 'Chọn Khối Lớp',
              icon: Icons.stairs_outlined,
              items: _khoiLopList,
              onChanged: (value) {
                setState(() {
                  _selectedKhoiLopID = value;
                });
              },
            ),
            _buildDropdown(
              value: _selectedDoiTuongID,
              hint: 'Chọn Đối Tượng',
              icon: Icons.school_outlined,
              items: _doiTuongList,
              onChanged: (value) {
                setState(() {
                  _selectedDoiTuongID = value;
                });
              },
            ),
            _buildDropdown(
              value: _selectedThoiGianDayID,
              hint: 'Chọn Thời Gian Dạy',
              icon: Icons.calendar_today_outlined,
              items: _thoiGianDayList,
              onChanged: (value) {
                setState(() {
                  _selectedThoiGianDayID = value;
                });
              },
            ),

            _buildTextFormField(
              controller: _hinhThucController,
              label: 'Hình thức (ví dụ: Online, Offline)',
              icon: Icons.computer_outlined,
            ),
            _buildTextFormField(
              controller: _hocPhiController,
              label: 'Học phí (vnd/buổi)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            _buildTextFormField(
              controller: _thoiLuongController,
              label: 'Thời lượng (ví dụ: 90 phút/buổi)',
              icon: Icons.schedule_outlined,
            ),
            _buildTextFormField(
              controller: _soLuongController,
              label: 'Số lượng học viên',
              icon: Icons.people_outline,
              keyboardType: TextInputType.number,
            ),
            _buildTextFormField(
              controller: _moTaController,
              label: 'Mô tả chi tiết',
              icon: Icons.notes_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Tạo Lớp'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required int? value,
    required String hint,
    required IconData icon,
    required List<DropdownItem> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<int>(
        value: value,
        hint: Text(hint),
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.ten),
              );
            }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Vui lòng chọn' : null,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        inputFormatters:
            keyboardType == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng không để trống';
          }
          return null;
        },
      ),
    );
  }
}
