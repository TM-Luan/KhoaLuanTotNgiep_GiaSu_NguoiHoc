// file: widgets/lich_hoc_dialogs.dart (THIẾT KẾ LẠI DIALOG)

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

// -------------------------------------------------------------------
// [SỬA] Dialog Sửa Link / Hủy Lớp (Thiết kế đẹp hơn)
// -------------------------------------------------------------------
class SuaLichHocDialog extends StatefulWidget {
  final LichHoc lichHoc;
  final Function(String? trangThai, String? duongDan) onUpdate;

  const SuaLichHocDialog({
    super.key,
    required this.lichHoc,
    required this.onUpdate,
  });

  @override
  State<SuaLichHocDialog> createState() => _SuaLichHocDialogState();
}

class _SuaLichHocDialogState extends State<SuaLichHocDialog> {
  late final TextEditingController _linkController;
  String? _selectedStatus;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    // Lớp Online là lớp có duongDan != null (kể cả khi link đang rỗng)
    _isOnline = widget.lichHoc.duongDan != null;

    _linkController = TextEditingController(
      text: widget.lichHoc.duongDan ?? '',
    );
    _selectedStatus = widget.lichHoc.trangThai;
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cập nhật buổi học',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'ID: ${widget.lichHoc.lichHocID}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chỉ hiển thị ô nhập link nếu là lớp ONLINE
              if (_isOnline) ...[
                Text(
                  'Link học Online',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: 'Link (Zoom, Meet...)',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const Divider(height: 32),
              ],

              // Dropdown để chọn HỦY LỚP
              Text(
                'Trạng thái',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: [
                  // Tùy chọn 1: Giữ nguyên trạng thái hiện tại
                  DropdownMenuItem(
                    value: widget.lichHoc.trangThai,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Hiện tại (${_getStatusText(widget.lichHoc.trangThai)})',
                        ),
                      ],
                    ),
                  ),
                  // Tùy chọn 2: Hủy lớp
                  const DropdownMenuItem(
                    value: 'Hủy',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          'Hủy buổi học này',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        ElevatedButton.icon(
          onPressed: _handleUpdate,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Lưu cập nhật'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _handleUpdate() {
    String? trangThaiMoi;
    if (_selectedStatus != widget.lichHoc.trangThai) {
      trangThaiMoi = _selectedStatus;
    }

    String? duongDanMoi;
    if (_isOnline) {
      final textMoi = _linkController.text.trim();
      final textCu = widget.lichHoc.duongDan ?? '';
      if (textMoi != textCu) {
        duongDanMoi = textMoi;
      }
    }

    // Chỉ gọi callback nếu có thay đổi
    if (trangThaiMoi != null || duongDanMoi != null) {
      widget.onUpdate(trangThaiMoi, duongDanMoi);
    }
    Navigator.pop(context);
  }

  // Helper để hiển thị tên trạng thái
  String _getStatusText(String trangThai) {
    switch (trangThai) {
      // case 'DaHoc':
      //   return 'Đã Học';
      // case 'DangDay':
      //   return 'Đang Dạy';
      case 'SapToi':
        return 'Sắp Tới';
      case 'Huy':
        return 'Đã Hủy';
      default:
        return trangThai;
    }
  }
}

// -------------------------------------------------------------------
// [MẪU] Dialog Xóa Lịch Học (Giữ nguyên)
// -------------------------------------------------------------------
class XoaLichHocDialog extends StatelessWidget {
  final LichHoc lichHoc;
  final Function(bool xoaCaChuoi) onDelete;

  const XoaLichHocDialog({
    super.key,
    required this.lichHoc,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool xoaCaChuoi = false;

    return AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bạn có chắc muốn xóa buổi học (ID: ${lichHoc.lichHocID}) không?',
              ),
              if (lichHoc.isLapLai)
                CheckboxListTile(
                  title: const Text('Xóa toàn bộ lịch của lớp này'),
                  value: xoaCaChuoi,
                  onChanged: (value) {
                    setDialogState(() {
                      xoaCaChuoi = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Không'),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete(xoaCaChuoi);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Xác nhận Xóa'),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------
// [MẪU] Dialog Chi Tiết Lịch Học (Giữ nguyên)
// -------------------------------------------------------------------
class ChiTietLichHocDialog extends StatelessWidget {
  final LichHoc lichHoc;
  final bool isGiaSu;

  const ChiTietLichHocDialog({
    super.key,
    required this.lichHoc,
    required this.isGiaSu,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chi tiết buổi học'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Mã lịch học:', '${lichHoc.lichHocID}'),
            _buildDetailRow('Môn học:', lichHoc.lopHoc?.tenMon ?? 'N/A'),
            _buildDetailRow(
              isGiaSu ? 'Học sinh:' : 'Gia sư:',
              isGiaSu
                  ? (lichHoc.lopHoc?.tenNguoiHoc ?? 'N/A')
                  : (lichHoc.lopHoc?.tenGiaSu ?? 'N/A'),
            ),
            _buildDetailRow('Trạng thái:', lichHoc.trangThai),
            _buildDetailRow('Ngày:', lichHoc.ngayHoc),
            _buildDetailRow(
              'Thời gian:',
              '${lichHoc.thoiGianBatDau} - ${lichHoc.thoiGianKetThuc}',
            ),
            if (lichHoc.duongDan != null)
              _buildDetailRow('Link:', lichHoc.duongDan!),
            if (lichHoc.lopHoc?.diaChi != null &&
                lichHoc.lopHoc!.diaChi!.isNotEmpty)
              _buildDetailRow('Địa chỉ:', lichHoc.lopHoc!.diaChi!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// [CŨ] Dialog Cập Nhật Trạng Thái (Có thể xóa nếu không dùng)
// -------------------------------------------------------------------
class CapNhatTrangThaiDialog extends StatelessWidget {
  final LichHoc lichHoc;
  final Function(String trangThai) onUpdate;

  const CapNhatTrangThaiDialog({
    super.key,
    required this.lichHoc,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật lịch dạy'),
      content: const Text('Bạn có muốn hủy buổi học này không?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Không'),
        ),
        ElevatedButton(
          onPressed: () {
            onUpdate('Hủy');
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Xác nhận Hủy'),
        ),
      ],
    );
  }
}
