import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
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
  final _lichHocMongMuonController = TextEditingController();

  int? _selectedMonID;
  int? _selectedKhoiLopID;
  int? _selectedDoiTuongID;
  String? _selectedHinhThuc;
  int? _selectedThoiLuong;
  int? _selectedSoBuoiTuan;

  List<DropdownItem> _monHocList = [];
  List<DropdownItem> _khoiLopList = [];
  List<DropdownItem> _doiTuongList = [];

  final List<String> _hinhThucOptions = ['Online', 'Offline'];
  final List<int> _thoiLuongOptions = [60, 90, 120];
  final List<int> _soBuoiOptions = [1, 2, 3, 4, 5];

  final Color _primaryColor = AppColors.primaryBlue;
  final Color _backgroundColor = const Color(0xFFF9FAFB);
  final Color _inputFillColor = Colors.white;
  final Color _borderColor = const Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _loadDropdownData().then((_) {
      if (isEditMode) _loadExistingClassData(widget.classId!);
    });
  }

  @override
  void dispose() {
    _hocPhiController.dispose();
    _soLuongController.dispose();
    _moTaController.dispose();
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
        _selectedSoBuoiTuan = lop.soBuoiTuan;
        _lichHocMongMuonController.text = lop.lichHocMongMuon ?? '';
      });
    }
  }

  // [SỬA LỖI] Logic submit form an toàn hơn
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final nguoiHocId = await _getNguoiHocIDFromProfile();
      if (nguoiHocId == null)
        throw Exception('Không tìm thấy thông tin người học.');

      // Làm sạch chuỗi học phí (chỉ giữ lại số)
      final cleanHocPhi = _hocPhiController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final data = {
        'NguoiHocID': nguoiHocId,
        'MonID': _selectedMonID,
        'KhoiLopID': _selectedKhoiLopID,
        'DoiTuongID': _selectedDoiTuongID,
        'HinhThuc': _selectedHinhThuc,
        'HocPhi': double.tryParse(cleanHocPhi) ?? 0, // Parse số an toàn
        'ThoiLuong': _selectedThoiLuong,
        'SoLuong': int.tryParse(_soLuongController.text) ?? 1,
        'MoTa': _moTaController.text,
        'SoBuoiTuan': _selectedSoBuoiTuan,
        'LichHocMongMuon':
            _lichHocMongMuonController.text.isEmpty
                ? null
                : _lichHocMongMuonController.text,
      };

      ApiResponse<LopHoc> res =
          isEditMode
              ? await _lopHocRepo.updateLopHoc(widget.classId!, data)
              : await _lopHocRepo.createLopHoc(data);

      if (!mounted) return;
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode ? 'Cập nhật thành công!' : 'Tạo lớp thành công!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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

  InputDecoration _cleanInputDecoration(
    String label,
    IconData icon, {
    bool isOptional = false,
  }) {
    return InputDecoration(
      labelText: label + (isOptional ? ' (Tuỳ chọn)' : ''),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true,
      fillColor: _inputFillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Chỉnh sửa lớp học' : 'Đăng tin tìm gia sư',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: _backgroundColor,
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
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.background, height: 1.0),
        ),
      ),
      body:
          _isDropdownLoading
              ? Center(child: CircularProgressIndicator(color: _primaryColor))
              : _dropdownError != null
              ? Center(child: Text(_dropdownError!))
              : _isSubmitting
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: _primaryColor),
                    const SizedBox(height: 16),
                    const Text('Đang xử lý...'),
                  ],
                ),
              )
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin môn học'),
            _buildDropdownField(
              _selectedMonID,
              'Môn học',
              _monHocList,
              onChanged: (v) => setState(() => _selectedMonID = v),
              icon: Icons.book_outlined,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    _selectedKhoiLopID,
                    'Lớp',
                    _khoiLopList,
                    onChanged: (v) => setState(() => _selectedKhoiLopID = v),
                    icon: Icons.stairs_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    _selectedDoiTuongID,
                    'Người dạy',
                    _doiTuongList,
                    onChanged: (v) => setState(() => _selectedDoiTuongID = v),
                    icon: Icons.school_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Yêu cầu & Chi phí'),

            _buildStringDropdownField(
              _selectedHinhThuc,
              'Hình thức',
              _hinhThucOptions,
              onChanged: (v) => setState(() => _selectedHinhThuc = v),
              icon: Icons.computer_outlined,
            ),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _hocPhiController,
                    label: 'Học phí/buổi',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIntDropdownField(
                    _selectedThoiLuong,
                    'Thời lượng',
                    _thoiLuongOptions,
                    onChanged: (v) => setState(() => _selectedThoiLuong = v),
                    icon: Icons.schedule_outlined,
                    suffix: ' phút',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Thời gian & Khác'),

            Row(
              children: [
                Expanded(
                  child: _buildSoBuoiDropdownField(
                    _selectedSoBuoiTuan,
                    'Số buổi',
                    _soBuoiOptions,
                    onChanged: (v) => setState(() => _selectedSoBuoiTuan = v),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _soLuongController,
                    label: 'Số học viên',
                    icon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            _buildTextField(
              controller: _lichHocMongMuonController,
              label: 'Lịch học mong muốn',
              icon: Icons.access_time,
              isOptional: true,
              placeholder: 'Vd: Tối thứ 2, thứ 4 (19h-21h)',
            ),

            _buildTextField(
              controller: _moTaController,
              label: 'Ghi chú thêm',
              icon: Icons.notes_outlined,
              maxLines: 3,
              isOptional: true,
              placeholder: 'Yêu cầu đặc biệt về gia sư...',
            ),

            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    int? value,
    String label,
    List<DropdownItem> items, {
    required ValueChanged<int?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: value,
        decoration: _cleanInputDecoration(label, icon),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        items:
            items
                .map(
                  (item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.ten)),
                )
                .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Bắt buộc' : null,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      ),
    );
  }

  Widget _buildStringDropdownField(
    String? value,
    String label,
    List<String> items, {
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _cleanInputDecoration(label, icon),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Bắt buộc' : null,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      ),
    );
  }

  Widget _buildIntDropdownField(
    int? value,
    String label,
    List<int> items, {
    required ValueChanged<int?> onChanged,
    required IconData icon,
    String suffix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: _cleanInputDecoration(label, icon),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text('$item$suffix'),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Bắt buộc' : null,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      ),
    );
  }

  Widget _buildSoBuoiDropdownField(
    int? value,
    String label,
    List<int> items, {
    required ValueChanged<int?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: _cleanInputDecoration(label, icon, isOptional: true),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text('$item buổi/tuần'),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (v) => null,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isOptional = false,
    String? placeholder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        inputFormatters:
            keyboardType == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
        decoration: _cleanInputDecoration(
          label,
          icon,
          isOptional: isOptional,
        ).copyWith(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        validator: (v) {
          if (!isOptional && (v == null || v.isEmpty)) {
            return 'Không được để trống';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.transparent,
        ),
        child: Text(
          isEditMode ? 'Lưu thay đổi' : 'Đăng yêu cầu',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
