import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SỬA: Thêm import
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
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

  // SỬA: Xóa _soBuoiTuanController, giữ _lichHocMongMuonController
  // final _soBuoiTuanController = TextEditingController(); // BỊ XÓA
  final _lichHocMongMuonController = TextEditingController();

  int? _selectedMonID;
  int? _selectedKhoiLopID;
  int? _selectedDoiTuongID;
  String? _selectedHinhThuc;
  int? _selectedThoiLuong;

  // SỬA: Thêm biến mới cho dropdown số buổi
  int? _selectedSoBuoiTuan;

  List<DropdownItem> _monHocList = [];
  List<DropdownItem> _khoiLopList = [];
  List<DropdownItem> _doiTuongList = [];

  final List<String> _hinhThucOptions = ['Online', 'Offline'];
  final List<int> _thoiLuongOptions = [60, 90, 120];

  // SỬA: Thêm danh sách tùy chọn số buổi
  final List<int> _soBuoiOptions = [1, 2, 3];

  @override
  void initState() {
    super.initState();
    _loadDropdownData().then((_) {
      if (isEditMode) _loadExistingClassData(widget.classId!);
    });
  }

  // SỬA: Xóa dispose của _soBuoiTuanController
  @override
  void dispose() {
    _hocPhiController.dispose();
    _soLuongController.dispose();
    _moTaController.dispose();
    // _soBuoiTuanController.dispose(); // BỊ XÓA
    _lichHocMongMuonController.dispose();
    super.dispose();
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
      ]);
      if (!mounted) return;
      setState(() {
        _monHocList = responses[0];
        _khoiLopList = responses[1];
        _doiTuongList = responses[2];
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
        _selectedHinhThuc = lop.hinhThuc;
        _selectedThoiLuong = lop.thoiLuong;
        _hocPhiController.text = lop.hocPhi;
        _soLuongController.text = lop.soLuong?.toString() ?? '1';
        _moTaController.text = lop.moTaChiTiet ?? '';

        // SỬA: Cập nhật logic load
        // _soBuoiTuanController.text = lop.soBuoiTuan?.toString() ?? ''; // BỊ XÓA
        _selectedSoBuoiTuan = lop.soBuoiTuan; // THAY THẾ
        _lichHocMongMuonController.text = lop.lichHocMongMuon ?? '';
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
        'HinhThuc': _selectedHinhThuc,
        'HocPhi': double.tryParse(_hocPhiController.text) ?? 0,
        'ThoiLuong': _selectedThoiLuong,
        'SoLuong': int.tryParse(_soLuongController.text) ?? 1,
        'MoTa': _moTaController.text,

        // SỬA: Cập nhật logic gửi đi
        'SoBuoiTuan': _selectedSoBuoiTuan, // THAY THẾ
        'LichHocMongMuon': _lichHocMongMuonController.text.isEmpty
            ? null
            : _lichHocMongMuonController.text,
      };

      ApiResponse<LopHoc> res = isEditMode
          ? await _lopHocRepo.updateLopHoc(widget.classId!, data)
          : await _lopHocRepo.createLopHoc(data);

      if (!mounted) return;
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Cập nhật lớp học thành công!'
                  : 'Tạo lớp học mới thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(res.message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Sửa Lớp Học' : 'Tạo Lớp Học Mới',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: AppTypography.appBarTitle,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.background),
          onPressed: () => Navigator.pop(context),
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
                      ? 'Chỉnh sửa thông tin lớp học'
                      : 'Thêm lớp học mới',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                  _selectedMonID,
                  'Chọn Môn Học',
                  _monHocList,
                  onChanged: (v) => setState(() => _selectedMonID = v),
                  icon: Icons.book_outlined,
                ),
                _buildDropdownField(
                  _selectedKhoiLopID,
                  'Chọn Chương Trình Lớp',
                  _khoiLopList,
                  onChanged: (v) => setState(() => _selectedKhoiLopID = v),
                  icon: Icons.stairs_outlined,
                ),
                _buildDropdownField(
                  _selectedDoiTuongID,
                  'Chọn Đối Tượng Dạy',
                  _doiTuongList,
                  onChanged: (v) => setState(() => _selectedDoiTuongID = v),
                  icon: Icons.school_outlined,
                ),
                _buildStringDropdownField(
                  _selectedHinhThuc,
                  'Chọn Hình Thức',
                  _hinhThucOptions,
                  onChanged: (v) => setState(() => _selectedHinhThuc = v),
                  icon: Icons.computer_outlined,
                ),
                _buildTextField(
                  controller: _hocPhiController,
                  label: 'Học phí (VNĐ/buổi)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number, // Thêm
                ),
                _buildIntDropdownField(
                  _selectedThoiLuong,
                  'Chọn Thời Lượng / Buổi', // Sửa
                  _thoiLuongOptions,
                  onChanged: (v) => setState(() => _selectedThoiLuong = v),
                  icon: Icons.schedule_outlined,
                ),

                // SỬA: Thay thế _buildTextField bằng _buildSoBuoiDropdownField
                _buildSoBuoiDropdownField(
                  _selectedSoBuoiTuan,
                  'Chọn Số Buổi / Tuần',
                  _soBuoiOptions,
                  onChanged: (v) => setState(() => _selectedSoBuoiTuan = v),
                  icon: Icons.calendar_today_outlined,
                ),
                _buildTextField(
                  controller: _lichHocMongMuonController,
                  label: 'Lịch học (Vd: Tối T2, T4)',
                  icon: Icons.access_time_outlined,
                  isOptional: true, // Không bắt buộc
                ),

                _buildTextField(
                  controller: _soLuongController,
                  label: 'Số lượng học viên',
                  icon: Icons.people_outline,
                  keyboardType: TextInputType.number, // Thêm
                ),
                _buildTextField(
                  controller: _moTaController,
                  label: 'Mô tả chi tiết',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                  isOptional: true, // Sửa
                ),

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
            .map(
              (item) =>
                  DropdownMenuItem(value: item.id, child: Text(item.ten)),
            )
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

  Widget _buildIntDropdownField(
    int? value,
    String hint,
    List<int> items, {
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
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text('$item phút/buổi'),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Vui lòng chọn' : null,
      ),
    );
  }

  // SỬA: Thêm Widget mới cho Dropdown Số Buổi
  Widget _buildSoBuoiDropdownField(
    int? value,
    String hint,
    List<int> items, {
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
            .map(
              (item) => DropdownMenuItem(
                value: item,
                // Hiển thị theo yêu cầu "X buổi/tuần"
                child: Text('$item buổi/tuần'),
              ),
            )
            .toList(),
        onChanged: onChanged,
        // Đặt là optional (không bắt buộc)
        validator: (v) => null,
      ),
    );
  }

  // SỬA: Cập nhật hàm này để hỗ trợ 'isOptional' và 'keyboardType'
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) {
          if (!isOptional && (v == null || v.isEmpty)) {
            return 'Vui lòng không để trống';
          }
          return null;
        },
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
            ),
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