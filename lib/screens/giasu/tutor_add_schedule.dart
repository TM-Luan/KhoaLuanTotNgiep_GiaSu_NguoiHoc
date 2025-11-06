import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class TaoLichHocPage extends StatefulWidget {
  final int lopYeuCauId;
  final String tenLop;

  const TaoLichHocPage({
    super.key,
    required this.lopYeuCauId,
    required this.tenLop,
  });

  @override
  State<TaoLichHocPage> createState() => _TaoLichHocPageState();
}

class _TaoLichHocPageState extends State<TaoLichHocPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _ngayHocController;
  late TextEditingController _thoiGianBatDauController;
  late TextEditingController _thoiGianKetThucController;
  late TextEditingController _duongDanController;

  // Form values
  DateTime _ngayHoc = DateTime.now();
  TimeOfDay _thoiGianBatDau = TimeOfDay.now();
  TimeOfDay _thoiGianKetThuc = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );
  String _trangThai = 'SapToi';
  bool _lapLai = false;
  int _soTuanLap = 4;
  String? _duongDan;

  @override
  void initState() {
    super.initState();
    _ngayHocController = TextEditingController();
    _thoiGianBatDauController = TextEditingController();
    _thoiGianKetThucController = TextEditingController();
    _duongDanController = TextEditingController();

    _updateControllers();
  }

  @override
  void dispose() {
    _ngayHocController.dispose();
    _thoiGianBatDauController.dispose();
    _thoiGianKetThucController.dispose();
    _duongDanController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    _ngayHocController.text = DateFormat('dd/MM/yyyy').format(_ngayHoc);
    _thoiGianBatDauController.text = _formatTimeOfDay(_thoiGianBatDau);
    _thoiGianKetThucController.text = _formatTimeOfDay(_thoiGianKetThuc);
    _duongDanController.text = _duongDan ?? '';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _selectNgayHoc() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngayHoc,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (picked != null && picked != _ngayHoc) {
      setState(() {
        _ngayHoc = picked;
        _updateControllers();
      });
    }
  }

  Future<void> _selectThoiGianBatDau() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _thoiGianBatDau,
    );

    if (picked != null) {
      setState(() {
        _thoiGianBatDau = picked;
        // Tự động set thời gian kết thúc = thời gian bắt đầu + 1.5 giờ
        final endHour = (picked.hour + 1) % 24;
        final endMinute = (picked.minute + 30) % 60;
        _thoiGianKetThuc = TimeOfDay(hour: endHour, minute: endMinute);
        _updateControllers();
      });
    }
  }

  Future<void> _selectThoiGianKetThuc() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _thoiGianKetThuc,
    );

    if (picked != null) {
      setState(() {
        _thoiGianKetThuc = picked;
        _updateControllers();
      });
    }
  }

  bool _validateForm() {
    // Kiểm tra thời gian kết thúc phải sau thời gian bắt đầu
    final batDauMinutes = _thoiGianBatDau.hour * 60 + _thoiGianBatDau.minute;
    final ketThucMinutes = _thoiGianKetThuc.hour * 60 + _thoiGianKetThuc.minute;

    if (ketThucMinutes <= batDauMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian kết thúc phải sau thời gian bắt đầu'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Kiểm tra nếu là online thì phải có đường dẫn
    if (_duongDanController.text.isNotEmpty) {
      final url = _duongDanController.text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đường dẫn phải bắt đầu bằng http:// hoặc https://'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  void _taoLichHoc() {
    if (!_validateForm()) return;

    // Format thời gian thành HH:mm:ss
    final thoiGianBatDau = '${_formatTimeOfDay(_thoiGianBatDau)}:00';
    final thoiGianKetThuc = '${_formatTimeOfDay(_thoiGianKetThuc)}:00';
    final ngayHoc = DateFormat('yyyy-MM-dd').format(_ngayHoc);

    // Gửi event tạo lịch học
    context.read<LichHocBloc>().add(
      CreateLichHoc(
        lopYeuCauId: widget.lopYeuCauId,
        thoiGianBatDau: thoiGianBatDau,
        thoiGianKetThuc: thoiGianKetThuc,
        ngayHoc: ngayHoc,
        lapLai: _lapLai,
        soTuanLap: _soTuanLap,
        duongDan:
            _duongDanController.text.isNotEmpty
                ? _duongDanController.text
                : null,
        trangThai: _trangThai,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool isRequired = true,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Vui lòng nhập $label';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitchField({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LichHocBloc, LichHocState>(
      listener: (context, state) {
        if (state is LichHocCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tạo thành công ${state.danhSachLichHoc.length} buổi học',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Delay một chút trước khi quay lại để người dùng thấy thông báo
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pop(context, true); // Quay lại và báo thành công
            }
          });
        } else if (state is LichHocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TẠO LỊCH HỌC'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _taoLichHoc,
              tooltip: 'Lưu lịch học',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Thông tin lớp
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin lớp',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Mã lớp: ${widget.lopYeuCauId}'),
                        Text('Tên lớp: ${widget.tenLop}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Ngày học
                _buildFormField(
                  label: 'Ngày học *',
                  controller: _ngayHocController,
                  onTap: _selectNgayHoc,
                ),

                // Thời gian bắt đầu
                _buildFormField(
                  label: 'Thời gian bắt đầu *',
                  controller: _thoiGianBatDauController,
                  onTap: _selectThoiGianBatDau,
                ),

                // Thời gian kết thúc
                _buildFormField(
                  label: 'Thời gian kết thúc *',
                  controller: _thoiGianKetThucController,
                  onTap: _selectThoiGianKetThuc,
                ),

                // Trạng thái
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trạng thái *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _trangThai,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'SapToi',
                          child: Text('Sắp tới'),
                        ),
                        DropdownMenuItem(
                          value: 'DangDay',
                          child: Text('Đang dạy'),
                        ),
                        DropdownMenuItem(value: 'DaHoc', child: Text('Đã học')),
                        DropdownMenuItem(value: 'Huy', child: Text('Đã hủy')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _trangThai = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

                // Đường dẫn (online)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đường dẫn (Online)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _duongDanController,
                      decoration: InputDecoration(
                        hintText: 'https://meet.google.com/...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _duongDan = value.isNotEmpty ? value : null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _duongDan != null
                          ? 'Hình thức: ONLINE'
                          : 'Hình thức: OFFLINE',
                      style: TextStyle(
                        color: _duongDan != null ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

                // Lặp lại
                _buildSwitchField(
                  title: 'Lặp lại hàng tuần',
                  subtitle:
                      'Tạo nhiều buổi học cùng khung giờ trong các tuần tiếp theo',
                  value: _lapLai,
                  onChanged: (value) {
                    setState(() {
                      _lapLai = value;
                    });
                  },
                ),

                // Số tuần lặp (chỉ hiện khi bật lặp lại)
                if (_lapLai) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số tuần lặp lại *',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _soTuanLap,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items: List.generate(12, (index) {
                          final week = index + 1;
                          return DropdownMenuItem(
                            value: week,
                            child: Text('$week tuần'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _soTuanLap = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sẽ tạo $_soTuanLap buổi học vào cùng khung giờ này',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],

                // Thông báo preview
                if (_lapLai) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📅 Lịch học sẽ được tạo:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (int i = 0; i < _soTuanLap; i++)
                            Text(
                              '• Tuần ${i + 1}: ${DateFormat('dd/MM/yyyy').format(_ngayHoc.add(Duration(days: i * 7)))} - ${_formatTimeOfDay(_thoiGianBatDau)} đến ${_formatTimeOfDay(_thoiGianKetThuc)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Nút tạo
                const SizedBox(height: 32),
                BlocBuilder<LichHocBloc, LichHocState>(
                  builder: (context, state) {
                    final isLoading = state is LichHocLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _taoLichHoc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child:
                            isLoading
                                ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Đang tạo...'),
                                  ],
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _lapLai
                                          ? 'TẠO $_soTuanLap BUỔI HỌC'
                                          : 'TẠO LỊCH HỌC',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
