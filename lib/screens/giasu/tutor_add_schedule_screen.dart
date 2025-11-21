import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';

class BuoiHocUI {
  int ngayThu;
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
  late TextEditingController _ngayBatDauController;
  late TextEditingController _duongDanController;
  DateTime _ngayBatDau = DateTime.now();
  int _soTuan = 4;
  final List<BuoiHocUI> _cacBuoiHoc = [];
  final List<String> _weekdayNames = [
    'Chủ Nhật',
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
  ];
  final TimeOfDay _defaultTime = const TimeOfDay(hour: 19, minute: 0);
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
    _soBuoiTuanLimit = _soBuoiTuan <= 0 ? 7 : _soBuoiTuan;
    if ((widget.lopHoc.lichHocMongMuon ?? '').isNotEmpty) {
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
    if (ngayThuChuaChon != -1) {
      setState(
        () => _cacBuoiHoc.add(
          BuoiHocUI(ngayThu: ngayThuChuaChon, thoiGianBatDau: _defaultTime),
        ),
      );
    }
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
    final duongDanNhap = _duongDanController.text.trim();
    if (widget.lopHoc.hinhThuc == 'Online' && duongDanNhap.isNotEmpty) {
      final uri = Uri.tryParse(duongDanNhap);
      if (uri == null || !uri.isAbsolute || uri.host.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đường dẫn không hợp lệ.'),
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
    final List<Map<String, dynamic>> buoiHocMau =
        _cacBuoiHoc
            .map(
              (b) => {
                'ngay_thu': b.ngayThu,
                'thoi_gian_bat_dau': '${_formatTimeOfDay(b.thoiGianBatDau)}:00',
              },
            )
            .toList();

    final String? finalDuongDan =
        (widget.lopHoc.hinhThuc == 'Online' &&
                _duongDanController.text.trim().isNotEmpty)
            ? _duongDanController.text.trim()
            : null;

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

  // --- UI HELPER ---
  InputDecoration _cleanInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
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
            ),
          );
          Future.delayed(
            const Duration(milliseconds: 1000),
            () => Navigator.pop(context, true),
          );
        } else if (state is LichHocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Tạo Lịch Học',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey.shade100, height: 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lopHoc.tieuDeLop,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_month_outlined,
                        'Lịch mong muốn',
                        _lichHocMongMuonText,
                      ),
                      _buildInfoRow(
                        Icons.repeat,
                        'Số buổi/tuần',
                        _soBuoiTuan > 0 ? '$_soBuoiTuan buổi' : 'Chưa rõ',
                      ),
                      _buildInfoRow(
                        Icons.access_time,
                        'Thời lượng',
                        '${widget.lopHoc.thoiLuong ?? 90} phút',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Schedule Editor
                _buildSectionTitle("Lịch học trong tuần"),
                if (_cacBuoiHoc.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Chưa thêm buổi học nào',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  )
                else
                  Column(
                    children:
                        _cacBuoiHoc
                            .asMap()
                            .entries
                            .map(
                              (entry) =>
                                  _buildBuoiHocItem(entry.value, entry.key),
                            )
                            .toList(),
                  ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        (_cacBuoiHoc.length >= _soBuoiTuanLimit)
                            ? null
                            : _themBuoiHoc,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm buổi học'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                _buildSectionTitle("Cấu hình thời gian"),

                // Date Picker
                TextFormField(
                  controller: _ngayBatDauController,
                  readOnly: true,
                  onTap: _selectNgayBatDau,
                  style: const TextStyle(fontSize: 15),
                  decoration: _cleanInputDecoration().copyWith(
                    labelText: "Ngày bắt đầu",
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Duration Dropdown
                DropdownButtonFormField<int>(
                  value: _soTuan,
                  items:
                      [4, 8, 12, 16, 24]
                          .map(
                            (week) => DropdownMenuItem(
                              value: week,
                              child: Text('$week tuần'),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _soTuan = val!),
                  decoration: _cleanInputDecoration().copyWith(
                    labelText: "Thời gian dạy",
                  ),
                ),

                if (widget.lopHoc.hinhThuc == 'Online') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _duongDanController,
                    style: const TextStyle(fontSize: 15),
                    decoration: _cleanInputDecoration(
                      hint: "https://...",
                    ).copyWith(labelText: "Link học Online (Tuỳ chọn)"),
                  ),
                ],

                const SizedBox(height: 40),

                // Submit Button
                BlocBuilder<LichHocBloc, LichHocState>(
                  builder: (context, state) {
                    final isLoading = state is LichHocLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            (isLoading || totalBuoi == 0) ? null : _taoLichHoc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : Text(
                                  'Xác nhận tạo ($totalBuoi buổi)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuoiHocItem(BuoiHocUI buoi, int index) {
    List<int> availableDays =
        List.generate(7, (i) => i)
            .where(
              (i) =>
                  i == buoi.ngayThu || !_cacBuoiHoc.any((b) => b.ngayThu == i),
            )
            .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Day Dropdown
          Expanded(
            flex: 3,
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<int>(
                  value: buoi.ngayThu,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  items:
                      availableDays
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                _weekdayNames[d],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => buoi.ngayThu = val!),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          // Time Picker
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: buoi.thoiGianBatDau,
                );
                if (picked != null) {
                  setState(() => buoi.thoiGianBatDau = picked);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    _formatTimeOfDay(buoi.thoiGianBatDau),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Delete Button
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.red.shade300,
              size: 20,
            ),
            onPressed: () => setState(() => _cacBuoiHoc.removeAt(index)),
          ),
        ],
      ),
    );
  }
}
