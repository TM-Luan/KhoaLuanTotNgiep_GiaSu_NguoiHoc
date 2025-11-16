// file: tutor_add_schedule_screen.dart (PHIÊN BẢN SỬA ĐA KHUNG GIỜ)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';

// [MỚI] Model để quản lý state của UI
class BuoiHocUI {
  int ngayThu; // 0=CN, 1=T2, ...
  TimeOfDay thoiGianBatDau;

  BuoiHocUI({required this.ngayThu, required this.thoiGianBatDau});
}

class TaoLichHocPage extends StatefulWidget {
  final LopHoc lopHoc;
  const TaoLichHocPage({super.key, required this.lopHoc});

  @override
  State<TaoLichHocPage> createState() => _TaoLichHocPageState();
}

class _TaoLichHocPageState extends State<TaoLichHocPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _ngayBatDauController;
  late TextEditingController _duongDanController;

  // Form values
  DateTime _ngayBatDau = DateTime.now();
  int _soTuan = 4;
  
  // State chính: Danh sách các buổi học (ngày + giờ)
  final List<BuoiHocUI> _cacBuoiHoc = [];
  
  final List<String> _weekdayNames = ['Chủ Nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
  final TimeOfDay _defaultTime = const TimeOfDay(hour: 19, minute: 0);

  // Thông tin lớp học (chỉ để hiển thị)
  String _lichHocMongMuonText = "Chưa rõ";
  int _soBuoiTuan = 0;
  int _soBuoiTuanLimit = 0;

  @override
  void initState() {
    super.initState();
    _parseLopHocInfo();
    _ngayBatDauController = TextEditingController();
    _duongDanController = TextEditingController();
    _updateControllers();
  }

  @override
  void dispose() {
    _ngayBatDauController.dispose();
    _duongDanController.dispose();
    super.dispose();
  }

  void _parseLopHocInfo() {
    _soBuoiTuan = widget.lopHoc.soBuoiTuan ?? 0;
    _soBuoiTuanLimit = _soBuoiTuan;

    if (_soBuoiTuanLimit <= 0) {
      _soBuoiTuanLimit = 7;
    }

    String lichMongMuon = widget.lopHoc.lichHocMongMuon ?? '';
    if (lichMongMuon.isNotEmpty) {
      _lichHocMongMuonText = widget.lopHoc.lichHocMongMuon!;
    } else if (_soBuoiTuan > 0) {
      _lichHocMongMuonText = "$_soBuoiTuan buổi/tuần (chưa rõ ngày)";
    }
  }

  void _updateControllers() {
    _ngayBatDauController.text = DateFormat('dd/MM/yyyy').format(_ngayBatDau);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _selectNgayBatDau() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngayBatDau,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _ngayBatDau) {
      setState(() {
        _ngayBatDau = picked;
        _updateControllers();
      });
    }
  }

  void _themBuoiHoc() {
    if (_cacBuoiHoc.length >= _soBuoiTuanLimit) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lớp học này chỉ có $_soBuoiTuanLimit buổi/tuần.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int ngayThuChuaChon = -1;
    for (int i = 0; i < 7; i++) {
      if (!_cacBuoiHoc.any((b) => b.ngayThu == i)) {
        ngayThuChuaChon = i;
        break;
      }
    }

    if (ngayThuChuaChon == -1) return; 

    setState(() {
      _cacBuoiHoc.add(
        BuoiHocUI(
          ngayThu: ngayThuChuaChon,
          thoiGianBatDau: _defaultTime,
        ),
      );
    });
  }

  bool _validateForm() {
    if (_cacBuoiHoc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một buổi học'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final duongDan = _duongDanController.text.trim();
    if (widget.lopHoc.hinhThuc == 'Online' && duongDan.isNotEmpty) {
      if (!duongDan.startsWith('http://') &&
          !duongDan.startsWith('https://')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đường dẫn nếu có nhập, phải bắt đầu bằng http:// hoặc https://'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _taoLichHoc() async {
    if (!_validateForm()) return;

    final List<Map<String, dynamic>> buoiHocMau = [];
    for (var buoi in _cacBuoiHoc) {
      buoiHocMau.add({
        'ngay_thu': buoi.ngayThu,
        'thoi_gian_bat_dau': '${_formatTimeOfDay(buoi.thoiGianBatDau)}:00',
      });
    }

    final String? finalDuongDan;
    final text = _duongDanController.text.trim();
    finalDuongDan = (widget.lopHoc.hinhThuc == 'Online' && text.isNotEmpty) ? text : null;

    context.read<LichHocBloc>().add(
      CreateLichHocTheoTuan(
        lopYeuCauId: widget.lopHoc.maLop,
        ngayBatDau: _ngayBatDau,
        soTuan: _soTuan,
        buoiHocMau: buoiHocMau,
        duongDan: finalDuongDan,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildScheduleEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Các buổi học trong tuần *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (_soBuoiTuanLimit > 0 && _soBuoiTuanLimit != 7)
              Text(
                '(Tối đa $_soBuoiTuanLimit buổi)',
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cacBuoiHoc.isEmpty)
          Center(
            child: Text(
              'Chưa thêm buổi học nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cacBuoiHoc.length,
          itemBuilder: (context, index) {
            return _buildBuoiHocItem(_cacBuoiHoc[index], index);
          },
        ),

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm buổi học'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
            onPressed: (_cacBuoiHoc.length >= _soBuoiTuanLimit) ? null : _themBuoiHoc,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBuoiHocItem(BuoiHocUI buoi, int index) {
    List<int> ngayChuaChon = [];
    for(int i=0; i<7; i++) {
      if (i == buoi.ngayThu || !_cacBuoiHoc.any((b) => b.ngayThu == i)) {
        ngayChuaChon.add(i);
      }
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: buoi.ngayThu,
                  isExpanded: true,
                  items: ngayChuaChon.map((ngay) {
                    return DropdownMenuItem<int>(
                      value: ngay,
                      child: Text(
                        _weekdayNames[ngay],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (newNgayThu) {
                    if (newNgayThu != null) {
                      setState(() {
                        buoi.ngayThu = newNgayThu;
                      });
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: buoi.thoiGianBatDau,
                  );
                  if (picked != null) {
                    setState(() {
                      buoi.thoiGianBatDau = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Center(
                    child: Text(
                      _formatTimeOfDay(buoi.thoiGianBatDau),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  _cacBuoiHoc.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalBuoi = _soTuan * _cacBuoiHoc.length;

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
          // [SỬA] Trả về true khi pop
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.pop(context, true); 
          });
        } else if (state is LichHocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: Text(
            'Tạo Lịch Tự Động',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              fontSize: AppTypography.appBarTitle,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _taoLichHoc,
              tooltip: 'Tạo lịch học',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lopHoc.tieuDeLop,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Lịch mong muốn (Gợi ý):',
                          _lichHocMongMuonText,
                        ),
                        _buildInfoRow(
                          Icons.repeat,
                          'Số buổi/tuần:',
                          _soBuoiTuan > 0 ? '$_soBuoiTuan buổi' : 'Chưa rõ',
                        ),
                        _buildInfoRow(
                          Icons.timelapse,
                          'Thời lượng:',
                          '${widget.lopHoc.thoiLuong ?? 90} phút/buổi',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildScheduleEditor(),

                _buildFormField(
                  label: 'Ngày áp dụng lịch *',
                  controller: _ngayBatDauController,
                  onTap: _selectNgayBatDau,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số tuần muốn tạo *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _soTuan,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items:
                          [4, 8, 12, 16, 24, 52].map((week) {
                            return DropdownMenuItem(
                              value: week,
                              child: Text('$week tuần'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _soTuan = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

                if (widget.lopHoc.hinhThuc == 'Online')
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
                          hintText: 'https://meet.google.com/... (có thể bỏ trống)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                if (_cacBuoiHoc.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📅 Sẽ tạo $_soTuan tuần, ${_cacBuoiHoc.length} buổi/tuần:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Áp dụng từ: ${DateFormat('dd/MM/yyyy').format(_ngayBatDau)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          ..._cacBuoiHoc.map((buoi) {
                            return Text(
                              '${_weekdayNames[buoi.ngayThu]} lúc: ${_formatTimeOfDay(buoi.thoiGianBatDau)}',
                              style: const TextStyle(fontSize: 14),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                          Text(
                            'Tổng cộng: $totalBuoi buổi học sẽ được tạo (API sẽ tự động kiểm tra trùng lịch).',
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                BlocBuilder<LichHocBloc, LichHocState>(
                  builder: (context, state) {
                    final isLoading = state is LichHocLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            (isLoading || totalBuoi == 0) ? null : _taoLichHoc,
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
                                      totalBuoi > 0
                                          ? 'TẠO $totalBuoi BUỔI HỌC'
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
    bool isOnline = false,
  }) {
    Color valueColor = Colors.black87;
    if (isWarning) valueColor = Colors.red;
    if (isOnline) valueColor = Colors.green.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}