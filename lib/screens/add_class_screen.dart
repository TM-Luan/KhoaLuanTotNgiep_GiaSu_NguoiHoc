// FILE: add_class_screen.dart
// (Thay thế toàn bộ file)

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/flutter_secure_storage.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:flutter/services.dart';
// Import repository và model mới
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/dropdown_repository.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _lopHocRepo = LopHocRepository();
  final _dropdownRepo = DropdownRepository(); // Repository mới
  
  bool _isSubmitting = false; // Trạng thái khi nhấn nút "Tạo Lớp"
  bool _isDropdownLoading = true; // Trạng thái khi tải dữ liệu dropdown
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

  // === BIẾN MỚI: Danh sách dữ liệu thật từ API ===
  List<DropdownItem> _monHocList = [];
  List<DropdownItem> _khoiLopList = [];
  List<DropdownItem> _doiTuongList = [];
  List<DropdownItem> _thoiGianDayList = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  // === HÀM MỚI: Tải dữ liệu cho 4 dropdown ===
  Future<void> _loadDropdownData() async {
    try {
      // Gọi cả 4 API song song
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
        _isDropdownLoading = false; // Tải xong
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

  // Hàm xử lý khi nhấn nút "Tạo Lớp"
  // === HÀM _submitForm ĐÃ ĐƯỢC VIẾT LẠI ===
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Dừng nếu form không hợp lệ
    }

    setState(() {
      _isSubmitting = true; // Bắt đầu gửi, khóa UI
    });

    String? errorMessage; // Biến tạm lưu lỗi

    try {
      // --- LẤY ID NGƯỜI HỌC THẬT ---
      final String? nguoiHocIdStr = await SecureStorage.getNguoiHocID(); // Gọi hàm lấy ID đã lưu

      if (nguoiHocIdStr == null || nguoiHocIdStr.isEmpty) {
        errorMessage = 'Lỗi: Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.';
        throw Exception(errorMessage); // Ném lỗi để dừng hàm
      }

      final int currentNguoiHocID = int.parse(nguoiHocIdStr); // Chuyển ID sang số
      // --- KẾT THÚC LẤY ID ---

      // Tạo dữ liệu để gửi đi
      Map<String, dynamic> lopHocData = {
        'NguoiHocID': currentNguoiHocID, // Dùng ID thật
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
      final ApiResponse<LopHoc> response =
          await _lopHocRepo.createLopHoc(lopHocData);

      if (!mounted) return; // Kiểm tra nếu widget đã bị hủy

      if (response.isSuccess) {
        // Thành công: Hiển thị thông báo và quay về trang trước
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo lớp học mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true để báo trang trước cần reload
      } else {
        // Thất bại từ API: Lấy lỗi từ response
        errorMessage = response.message;
        throw Exception(errorMessage); // Ném lỗi để hiển thị
      }
    } catch (e) {
      // Bắt lỗi chung (lỗi mạng, lỗi parse ID, lỗi từ API...)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Lỗi không xác định: $e'), // Hiển thị lỗi cụ thể nếu có
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Luôn chạy cuối cùng: Mở khóa UI
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  // === KẾT THÚC HÀM _submitForm ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Lớp Học Mới'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      // Hiển thị Body dựa trên trạng thái tải
      body: _buildBody(),
    );
  }

  // Widget xây dựng Body
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
            )
          ],
        ),
      );
    }

    // Nếu đang gửi form thì khóa UI lại
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

    // Hiển thị form
    return _buildForm();
  }

  // Widget xây dựng Form
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

            // === DROPDOWN ĐÃ CẬP NHẬT DÙNG DỮ LIỆU THẬT ===
            _buildDropdown(
              value: _selectedMonID,
              hint: 'Chọn Môn Học',
              icon: Icons.book_outlined,
              items: _monHocList,
              onChanged: (value) {
                setState(() { _selectedMonID = value; });
              },
            ),
            _buildDropdown(
              value: _selectedKhoiLopID,
              hint: 'Chọn Khối Lớp',
              icon: Icons.stairs_outlined,
              items: _khoiLopList,
              onChanged: (value) {
                setState(() { _selectedKhoiLopID = value; });
              },
            ),
            _buildDropdown(
              value: _selectedDoiTuongID,
              hint: 'Chọn Đối Tượng',
              icon: Icons.school_outlined,
              items: _doiTuongList,
              onChanged: (value) {
                setState(() { _selectedDoiTuongID = value; });
              },
            ),
            _buildDropdown(
              value: _selectedThoiGianDayID,
              hint: 'Chọn Thời Gian Dạy',
              icon: Icons.calendar_today_outlined,
              items: _thoiGianDayList,
              onChanged: (value) {
                setState(() { _selectedThoiGianDayID = value; });
              },
            ),

            // --- Các ô Text (giữ nguyên) ---
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

            // --- Nút Submit ---
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Tạo Lớp'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để xây dựng Dropdown
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
        items: items.map((item) {
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

  // Widget helper để xây dựng TextFormField (giữ nguyên)
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
        inputFormatters: keyboardType == TextInputType.number
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