// file: widgets/lich_hoc_dialogs.dart (CHO PHÉP TRỐNG LINK)

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

// DIALOG SỬA LỊCH HỌC
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

  @override
  void initState() {
    super.initState();
    _selectedTrangThai = widget.lichHoc.trangThai;
    _duongDanController =
        TextEditingController(text: widget.lichHoc.duongDan ?? '');

    
    if (_selectedTrangThai == 'Huy') {
      _cacTrangThai.removeWhere((item) => item['value'] != 'Huy');
    }
    else if (_selectedTrangThai == 'DaHoc') {
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
    {'value': 'DangDay', 'text': 'Đang Dạy'},
    {'value': 'DaHoc', 'text': 'Đã Học'},
    {'value': 'Huy', 'text': 'Hủy buổi học'},
  ];

  // [SỬA] Cập nhật hàm validate (CHO PHÉP TRỐNG)
  String? _validateDuongDan(String? value) {
    // Dùng widget.isOnlineClass
    if (!widget.isOnlineClass) return null; 

    final text = value?.trim() ?? "";
    
    // [SỬA] Nếu text rỗng -> Hợp lệ (cho phép trống)
    if (text.isEmpty) {
        return null;
    }

    // [SỬA] Nếu text không rỗng, dùng Uri.tryParse (dễ dãi)
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.isAbsolute || uri.host.isEmpty) {
      return 'Link không hợp lệ. (vd: https://google.com)';
    }
    
    return null; // Hợp lệ
  }

  // [SỬA] Cập nhật hàm update (CHO PHÉP TRỐNG)
  void _handleUpdate() {
    // Chỉ chạy khi form hợp lệ
    if (_formKey.currentState!.validate()) {
      
      String? finalDuongDan;
      final text = _duongDanController.text.trim();

      // [SỬA] Nếu là Online VÀ text không rỗng -> gán text
      if (widget.isOnlineClass && text.isNotEmpty) {
        finalDuongDan = text;
      } else {
        // Lớp offline, hoặc lớp Online nhưng để trống -> gán null
        finalDuongDan = null;
      }

      widget.onUpdate(
        _selectedTrangThai,
        finalDuongDan,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật buổi học'),
      content: Form(
        key: _formKey, // Thêm form key
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
              const Text(
                'Cập nhật trạng thái:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTrangThai,
                isExpanded: true,
                items: _cacTrangThai.map((item) {
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
                onChanged: (widget.lichHoc.trangThai == 'DaHoc' || widget.lichHoc.trangThai == 'Huy')
                    ? null // Vô hiệu hóa nếu đã học hoặc đã hủy
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
                  filled: (widget.lichHoc.trangThai == 'DaHoc' || widget.lichHoc.trangThai == 'Huy'),
                  fillColor: Colors.grey[200],
                ),
              ),
              
              if (widget.isOnlineClass) ...[
                const SizedBox(height: 16),
                const Text(
                  'Cập nhật đường dẫn (Online):',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _duongDanController,
                  decoration: InputDecoration(
                    hintText: 'https://... (Có thể bỏ trống)', // [SỬA]
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  validator: _validateDuongDan, // validator đã được cập nhật
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
          onPressed: _handleUpdate, // hàm update đã được cập nhật
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

// (Các dialog ChiTiet và Xoa giữ nguyên)

class ChiTietLichHocDialog extends StatelessWidget {
  final LichHoc lichHoc;
  final bool isGiaSu;
  const ChiTietLichHocDialog({super.key, required this.lichHoc, required this.isGiaSu});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chi tiết buổi học ${lichHoc.lichHocID}'),
      content: const Text('Nội dung chi tiết...'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        )
      ],
    );
  }
}

class XoaLichHocDialog extends StatelessWidget {
  final LichHoc lichHoc;
  final Function(bool xoaCaChuoi) onDelete;
  const XoaLichHocDialog({super.key, required this.lichHoc, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Xóa buổi học ${lichHoc.lichHocID}'),
      content: const Text('Bạn có chắc muốn xóa?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete(false); // Ví dụ: Xóa 1 buổi
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Xóa'),
        )
      ],
    );
  }
}