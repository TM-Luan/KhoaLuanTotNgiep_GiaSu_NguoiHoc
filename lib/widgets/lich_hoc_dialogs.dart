// file: widgets/lich_hoc_dialogs.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

// ============================================================================
// 1. DIALOG SỬA LỊCH HỌC (CẬP NHẬT TRẠNG THÁI & LINK)
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
  final _formKey = GlobalKey<FormState>(); // Key để quản lý form validation

  @override
  void initState() {
    super.initState();
    _selectedTrangThai = widget.lichHoc.trangThai;
    _duongDanController = TextEditingController(
      text: widget.lichHoc.duongDan ?? '',
    );

    // Logic kinh doanh: Nếu đã Hủy hoặc Đã học thì không cho sửa sang trạng thái khác
    // (Hoặc chỉ hiển thị chính nó trong dropdown)
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

  final List<Map<String, dynamic>> _cacTrangThai = [
    {'value': 'SapToi', 'text': 'Sắp Tới'},
    {'value': 'Huy', 'text': 'Hủy buổi học'},
  ];

  // --- HÀM VALIDATE ---
  String? _validateDuongDan(String? value) {
    // 1. Nếu không phải lớp Online -> Không cần validate
    if (!widget.isOnlineClass) return null;

    final text = value?.trim() ?? "";

    // 2. Cho phép để trống (Optional)
    if (text.isEmpty) {
      return null;
    }

    // 3. Nếu đã nhập, bắt buộc phải đúng định dạng URL (http hoặc https)
    final urlPattern = RegExp(r'^(http|https):\/\/[^\s$.?#].[^\s]*$');
    if (!urlPattern.hasMatch(text)) {
      return 'không phải định dạng URL hợp lệ ';
    }

    return null; // Hợp lệ
  }

  // --- HÀM XỬ LÝ CẬP NHẬT ---
  void _handleUpdate() {
    // Chỉ xử lý khi form hợp lệ (các validator trả về null)
    if (_formKey.currentState!.validate()) {
      String? finalDuongDan;
      final text = _duongDanController.text.trim();

      // Logic gán dữ liệu:
      // - Nếu là lớp Online VÀ có nhập text -> Lấy text đó.
      // - Các trường hợp còn lại -> Gán null.
      if (widget.isOnlineClass && text.isNotEmpty) {
        finalDuongDan = text;
      } else {
        finalDuongDan = null;
      }

      widget.onUpdate(_selectedTrangThai, finalDuongDan);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái để disable dropdown nếu cần
    final bool isLocked =
        (widget.lichHoc.trangThai == 'DaHoc' ||
            widget.lichHoc.trangThai == 'Huy');

    return AlertDialog(
      title: const Text('Cập nhật buổi học'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mã buổi học: ${widget.lichHoc.lichHocID}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // --- Dropdown Trạng Thái ---
              const Text(
                'Cập nhật trạng thái:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTrangThai,
                isExpanded: true,
                items:
                    _cacTrangThai.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],
                        child: Text(
                          item['text'],
                          style: TextStyle(
                            color: item['value'] == 'Huy' ? Colors.red : null,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged:
                    isLocked
                        ? null // Disable nếu bị khóa
                        : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTrangThai = value;
                            });
                          }
                        },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: isLocked,
                  fillColor: Colors.grey[200],
                ),
              ),

              // --- Input Link Online (Chỉ hiện nếu là lớp Online) ---
              if (widget.isOnlineClass) ...[
                const SizedBox(height: 16),
                const Text(
                  'Cập nhật đường dẫn:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _duongDanController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: 'https://meet.google.com/...',
                    helperText: 'Có thể bỏ trống', // Hướng dẫn người dùng
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  validator: _validateDuongDan, // Gắn hàm validate vào đây
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Thoát'),
        ),
        ElevatedButton(
          onPressed: _handleUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cập nhật'),
        ),
      ],
    );
  }
}

// ============================================================================
// 2. DIALOG CHI TIẾT LỊCH HỌC (XEM THÔNG TIN)
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
      final date = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Chi tiết buổi học',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTile('Mã lịch học', '${lichHoc.lichHocID}'),
            _buildTile('Môn học', lichHoc.lopHoc?.tenMon ?? 'N/A'),
            _buildTile(
              isGiaSu ? 'Học sinh' : 'Gia sư',
              isGiaSu
                  ? (lichHoc.lopHoc?.tenNguoiHoc ?? 'N/A')
                  : (lichHoc.lopHoc?.tenGiaSu ?? 'N/A'),
            ),
            _buildTile('Ngày', _formatDate(lichHoc.ngayHoc)),
            _buildTile(
              'Thời gian',
              '${lichHoc.thoiGianBatDau} - ${lichHoc.thoiGianKetThuc}',
            ),
            if (lichHoc.duongDan != null && lichHoc.duongDan!.isNotEmpty)
              _buildTile('Link', lichHoc.duongDan!),
            if (lichHoc.lopHoc?.diaChi != null &&
                lichHoc.lopHoc!.diaChi!.isNotEmpty)
              _buildTile('Địa chỉ', lichHoc.lopHoc!.diaChi!),

            const SizedBox(height: 10),
            _buildStatusBadge(lichHoc.trangThai),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildTile(String label, String value) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const Divider(height: 1),
      ],
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
        text = 'Đang diễn ra';
        color = Colors.green;
        break;
      case 'DaHoc':
        text = 'Đã hoàn thành';
        color = Colors.grey;
        break;
      case 'Huy':
        text = 'Đã hủy';
        color = Colors.red;
        break;
      default:
        text = status;
        color = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
