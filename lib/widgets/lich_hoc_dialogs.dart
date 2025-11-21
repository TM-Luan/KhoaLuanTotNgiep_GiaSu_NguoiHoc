import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

// ============================================================================
// 1. DIALOG SỬA LỊCH HỌC (Modern Style)
// ============================================================================
class SuaLichHocDialog extends StatefulWidget {
  final LichHoc lichHoc;
  final Function(String trangThai, String? duongDan) onUpdate;
  final bool isOnlineClass;

  const SuaLichHocDialog({
    super.key,
    required this.lichHoc,
    required this.onUpdate,
    required this.isOnlineClass,
  });

  @override
  State<SuaLichHocDialog> createState() => _SuaLichHocDialogState();
}

class _SuaLichHocDialogState extends State<SuaLichHocDialog> {
  late String _selectedTrangThai;
  late TextEditingController _duongDanController;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _cacTrangThai = [
    {'value': 'SapToi', 'text': 'Sắp Tới'},
    {'value': 'Huy', 'text': 'Hủy buổi học'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTrangThai = widget.lichHoc.trangThai;
    _duongDanController = TextEditingController(
      text: widget.lichHoc.duongDan ?? '',
    );

    if (_selectedTrangThai == 'Huy') {
      _cacTrangThai.removeWhere((item) => item['value'] != 'Huy');
    } else if (_selectedTrangThai == 'DaHoc') {
      _cacTrangThai.removeWhere((item) => item['value'] != 'DaHoc');
    }
  }

  @override
  void dispose() {
    _duongDanController.dispose();
    super.dispose();
  }

  String? _validateDuongDan(String? value) {
    if (!widget.isOnlineClass) return null;
    final text = value?.trim() ?? "";
    if (text.isEmpty) return null;
    final urlPattern = RegExp(r'^(http|https):\/\/[^\s$.?#].[^\s]*$');
    if (!urlPattern.hasMatch(text)) return 'Link không hợp lệ';
    return null;
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      String? finalDuongDan =
          (widget.isOnlineClass && _duongDanController.text.trim().isNotEmpty)
              ? _duongDanController.text.trim()
              : null;
      widget.onUpdate(_selectedTrangThai, finalDuongDan);
      Navigator.pop(context);
    }
  }

  // UI Helper: Modern Input Decoration
  InputDecoration _inputDecoration(String hint) {
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked =
        (widget.lichHoc.trangThai == 'DaHoc' ||
            widget.lichHoc.trangThai == 'Huy');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cập nhật buổi học',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Trạng thái'),
              DropdownButtonFormField<String>(
                value: _selectedTrangThai,
                items:
                    _cacTrangThai
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['value'],
                            child: Text(
                              item['text'],
                              style: TextStyle(
                                color:
                                    item['value'] == 'Huy'
                                        ? Colors.red
                                        : Colors.black87,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    isLocked
                        ? null
                        : (value) =>
                            setState(() => _selectedTrangThai = value!),
                decoration: _inputDecoration("Chọn trạng thái"),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade400,
                ),
              ),

              if (widget.isOnlineClass) ...[
                const SizedBox(height: 16),
                _buildLabel('Link học Online'),
                TextFormField(
                  controller: _duongDanController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(fontSize: 15),
                  decoration: _inputDecoration('https://meet.google.com/...'),
                  validator: _validateDuongDan,
                ),
              ],

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Lưu',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

// ============================================================================
// 2. DIALOG CHI TIẾT LỊCH HỌC (Modern Style)
// ============================================================================
class ChiTietLichHocDialog extends StatelessWidget {
  final LichHoc lichHoc;
  final bool isGiaSu;

  const ChiTietLichHocDialog({
    super.key,
    required this.lichHoc,
    required this.isGiaSu,
  });

  String _formatDate(String rawDate) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chi tiết buổi học',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStatusBadge(lichHoc.trangThai),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.tag, 'Mã lịch', '${lichHoc.lichHocID}'),
            _buildDetailRow(
              Icons.book_outlined,
              'Môn học',
              lichHoc.lopHoc?.tenMon ?? 'N/A',
            ),
            _buildDetailRow(
              isGiaSu ? Icons.person_outline : Icons.school_outlined,
              isGiaSu ? 'Học viên' : 'Gia sư',
              isGiaSu
                  ? (lichHoc.lopHoc?.tenNguoiHoc ?? 'N/A')
                  : (lichHoc.lopHoc?.tenGiaSu ?? 'N/A'),
            ),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Ngày',
              _formatDate(lichHoc.ngayHoc),
            ),
            _buildDetailRow(
              Icons.access_time,
              'Thời gian',
              '${lichHoc.thoiGianBatDau} - ${lichHoc.thoiGianKetThuc}',
            ),

            if (lichHoc.duongDan != null && lichHoc.duongDan!.isNotEmpty)
              _buildDetailRow(
                Icons.link,
                'Link',
                lichHoc.duongDan!,
                isLink: true,
              ),

            if (lichHoc.lopHoc?.diaChi != null &&
                lichHoc.lopHoc!.diaChi!.isNotEmpty)
              _buildDetailRow(
                Icons.location_on_outlined,
                'Địa chỉ',
                lichHoc.lopHoc!.diaChi!,
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isLink ? Colors.blue : Colors.black87,
                    decoration: isLink ? TextDecoration.underline : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String text;
    Color color;
    switch (status) {
      case 'SapToi':
        text = 'Sắp tới';
        color = Colors.blue;
        break;
      case 'DangDay':
        text = 'Đang dạy';
        color = Colors.orange;
        break;
      case 'DaHoc':
        text = 'Hoàn thành';
        color = Colors.green;
        break;
      case 'Huy':
        text = 'Đã hủy';
        color = Colors.red;
        break;
      default:
        text = status;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
