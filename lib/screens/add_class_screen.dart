import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/dropdown_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';

class AddClassPage extends StatefulWidget {
  final int? classId;
  const AddClassPage({super.key, this.classId});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _lopHocRepo = LopHocRepository();
  final _dropdownRepo = DropdownRepository();
  final _authRepo = AuthRepository();

  bool get isEditMode => widget.classId != null;
  bool _isSubmitting = false;
  bool _isDropdownLoading = true;
  String? _dropdownError;

  final _hocPhiController = TextEditingController();
  final _soLuongController = TextEditingController(text: '1');
  final _moTaController = TextEditingController();

  int? _selectedMonID;
  int? _selectedKhoiLopID;
  int? _selectedDoiTuongID;
  int? _selectedThoiGianDayID;
  String? _selectedHinhThuc;
  String? _selectedThoiLuong;

  List<DropdownItem> _monHocList = [];
  List<DropdownItem> _khoiLopList = [];
  List<DropdownItem> _doiTuongList = [];
  List<DropdownItem> _thoiGianDayList = [];

  final List<String> _hinhThucOptions = ['Online', 'Offline'];
  final List<String> _thoiLuongOptions = [
    '60 phút/buổi',
    '90 phút/buổi',
    '120 phút/buổi',
  ];

  @override
  void initState() {
    super.initState();
    _loadDropdownData().then((_) {
      if (isEditMode) _loadExistingClassData(widget.classId!);
    });
  }

  Future<int?> _getNguoiHocIDFromProfile() async {
    final response = await _authRepo.getProfile();
    if (response.success && response.data != null) {
      final user = response.data!;
      return user.nguoiHocID;
    }
    return null;
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

  Future<void> _loadExistingClassData(int classId) async {
    final response = await _lopHocRepo.getLopHocById(classId);
    if (response.success && response.data != null) {
      final lop = response.data!;
      setState(() {
        _selectedMonID = lop.monId;
        _selectedKhoiLopID = lop.khoiLopId;
        _selectedDoiTuongID = lop.doiTuongID;
        _selectedThoiGianDayID = lop.thoiGianDayID;
        _selectedHinhThuc = lop.hinhThuc;
        _selectedThoiLuong = lop.thoiLuong;
        _hocPhiController.text = lop.hocPhi;
        _soLuongController.text = lop.soLuong?.toString() ?? '1';
        _moTaController.text = lop.moTaChiTiet ?? '';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final nguoiHocId = await _getNguoiHocIDFromProfile();
      if (nguoiHocId == null) throw Exception('Không tìm thấy người học.');

      final data = {
        'NguoiHocID': nguoiHocId,
        'MonID': _selectedMonID,
        'KhoiLopID': _selectedKhoiLopID,
        'DoiTuongID': _selectedDoiTuongID,
        'ThoiGianDayID': _selectedThoiGianDayID,
        'HinhThuc': _selectedHinhThuc,
        'HocPhi': double.tryParse(_hocPhiController.text) ?? 0,
        'ThoiLuong': _selectedThoiLuong,
        'SoLuong': int.tryParse(_soLuongController.text) ?? 1,
        'MoTaChiTiet': _moTaController.text,
      };

      ApiResponse<LopHoc> res = isEditMode
          ? await _lopHocRepo.updateLopHoc(widget.classId!, data)
          : await _lopHocRepo.createLopHoc(data);

      if (!mounted) return;
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEditMode
              ? 'Cập nhật lớp học thành công!'
              : 'Tạo lớp học mới thành công!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, true);
      } else {
        throw Exception(res.message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEditMode ? 'Sửa Lớp Học' : 'Tạo Lớp Học Mới'),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _isDropdownLoading
          ? const Center(child: CircularProgressIndicator())
          : _dropdownError != null
              ? Center(child: Text(_dropdownError!))
              : _isSubmitting
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Đang xử lý...'),
                        ],
                      ),
                    )
                  : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditMode
                      ? '📝 Chỉnh sửa thông tin lớp học'
                      : '📚 Thêm lớp học mới',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                    _selectedMonID, 'Chọn Môn Học', _monHocList,
                    onChanged: (v) => setState(() => _selectedMonID = v),
                    icon: Icons.book_outlined),
                _buildDropdownField(
                    _selectedKhoiLopID, 'Chọn Khối Lớp', _khoiLopList,
                    onChanged: (v) => setState(() => _selectedKhoiLopID = v),
                    icon: Icons.stairs_outlined),
                _buildDropdownField(
                    _selectedDoiTuongID, 'Chọn Đối Tượng', _doiTuongList,
                    onChanged: (v) => setState(() => _selectedDoiTuongID = v),
                    icon: Icons.school_outlined),
                _buildDropdownField(_selectedThoiGianDayID, 'Chọn Thời Gian Dạy',
                    _thoiGianDayList,
                    onChanged: (v) => setState(() => _selectedThoiGianDayID = v),
                    icon: Icons.access_time_outlined),
                _buildStringDropdownField(
                    _selectedHinhThuc, 'Chọn Hình Thức', _hinhThucOptions,
                    onChanged: (v) => setState(() => _selectedHinhThuc = v),
                    icon: Icons.computer_outlined),
                _buildTextField(
                    controller: _hocPhiController,
                    label: 'Học phí (VNĐ/buổi)',
                    icon: Icons.attach_money),
                _buildStringDropdownField(
                    _selectedThoiLuong, 'Chọn Thời Lượng', _thoiLuongOptions,
                    onChanged: (v) => setState(() => _selectedThoiLuong = v),
                    icon: Icons.schedule_outlined),
                _buildTextField(
                    controller: _soLuongController,
                    label: 'Số lượng học viên',
                    icon: Icons.people_outline),
                _buildTextField(
                    controller: _moTaController,
                    label: 'Mô tả chi tiết',
                    icon: Icons.notes_outlined,
                    maxLines: 3),

                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    int? value,
    String hint,
    List<DropdownItem> items, {
    required ValueChanged<int?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((item) =>
                DropdownMenuItem(value: item.id, child: Text(item.ten)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Vui lòng chọn' : null,
      ),
    );
  }

  Widget _buildStringDropdownField(
    String? value,
    String hint,
    List<String> items, {
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Vui lòng chọn' : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Vui lòng không để trống' : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return InkWell(
      onTap: _submitForm,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            isEditMode ? 'Lưu Thay Đổi' : 'Tạo Lớp Ngay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
