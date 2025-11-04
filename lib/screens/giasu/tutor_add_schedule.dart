// tao_lich_hoc_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

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
  DateTime.now()
      .add(const Duration(hours: 1)),
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
        _thoiGianKetThuc = TimeOfDay(
          hour: (picked.hour + 1) % 24,
          minute: (picked.minute + 30) % 60,
        );
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
        const SnackBar(content: Text('Thời gian kết thúc phải sau thời gian bắt đầu')),
      );
      return false;
    }
    
    // Kiểm tra nếu là online thì phải có đường dẫn
    if (_duongDanController.text.isNotEmpty) {
      final url = _duongDanController.text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đường dẫn phải bắt đầu bằng http:// hoặc https://')),
        );
        return false;
      }
    }
    
    return true;
  }

  void _taoLichHoc() {
    if (!_validateForm()) return;
    
    final request = TaoLichHocRequest(
      thoiGianBatDau: '${_formatTimeOfDay(_thoiGianBatDau)}:00',
      thoiGianKetThuc: '${_formatTimeOfDay(_thoiGianKetThuc)}:00',
      ngayHoc: DateFormat('yyyy-MM-dd').format(_ngayHoc),
      duongDan: _duongDanController.text.isNotEmpty ? _duongDanController.text : null,
      trangThai: _trangThai,
      lapLai: _lapLai,
      soTuanLap: _lapLai ? _soTuanLap : null,
    );

    if (_lapLai) {
      context.read<LichHocBloc>().add(
        TaoLichHocLapLaiEvent(widget.lopYeuCauId, request),
      );
    } else {
      context.read<LichHocBloc>().add(
        TaoLichHocEvent(widget.lopYeuCauId, request),
      );
    }
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        if (state is TaoLichHocSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Quay lại và báo thành công
        } else if (state is LichHocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _trangThai,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'SapToi', child: Text('Sắp tới')),
                        DropdownMenuItem(value: 'DangDay', child: Text('Đang dạy')),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _duongDanController,
                      decoration: InputDecoration(
                        hintText: 'https://meet.google.com/...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _duongDan = value.isNotEmpty ? value : null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _duongDan != null ? 'Hình thức: ONLINE' : 'Hình thức: OFFLINE',
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
                  subtitle: 'Tạo nhiều buổi học cùng khung giờ trong các tuần tiếp theo',
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _soTuanLap,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],

                // Nút tạo
                const SizedBox(height: 32),
                BlocBuilder<LichHocBloc, LichHocState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is LichHocLoading ? null : _taoLichHoc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: state is LichHocLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'TẠO LỊCH HỌC',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}