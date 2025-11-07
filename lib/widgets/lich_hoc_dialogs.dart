import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';
import 'package:intl/intl.dart';

/// Dialog hiển thị chi tiết lịch học
class ChiTietLichHocDialog extends StatelessWidget {
  final LichHoc lichHoc;
  final bool isGiaSu; // true = Gia sư, false = Người học

  const ChiTietLichHocDialog({
    super.key,
    required this.lichHoc,
    required this.isGiaSu,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = (lichHoc.duongDan ?? '').isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết lịch học',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Thông tin cơ bản
              _buildInfoRow(
                icon: Icons.tag,
                title: 'Mã lịch học',
                content: '#${lichHoc.lichHocID}',
              ),
              _buildInfoRow(
                icon: Icons.school,
                title: 'Mã lớp học',
                content: '#${lichHoc.lopYeuCauID}',
              ),
              if (lichHoc.lopHoc?.tenMon != null)
                _buildInfoRow(
                  icon: Icons.book,
                  title: 'Môn học',
                  content: lichHoc.lopHoc!.tenMon!,
                ),
              if (isGiaSu && lichHoc.lopHoc?.tenNguoiHoc != null)
                _buildInfoRow(
                  icon: Icons.person,
                  title: 'Học sinh',
                  content: lichHoc.lopHoc?.tenNguoiHoc ?? '',
                ),
              if (!isGiaSu && lichHoc.lopHoc?.tenGiaSu != null)
                _buildInfoRow(
                  icon: Icons.person_outline,
                  title: 'Gia sư',
                  content: lichHoc.lopHoc?.tenGiaSu ?? '',
                ),

              const Divider(height: 24),

              // Thời gian
              _buildInfoRow(
                icon: Icons.calendar_today,
                title: 'Ngày học',
                content: _formatDate(lichHoc.ngayHoc),
              ),
              _buildInfoRow(
                icon: Icons.access_time,
                title: 'Thời gian',
                content:
                    '${_formatTime(lichHoc.thoiGianBatDau)} - ${_formatTime(lichHoc.thoiGianKetThuc)}',
              ),

              const Divider(height: 24),

              // Trạng thái
              _buildInfoRow(
                icon: Icons.info_outline,
                title: 'Trạng thái',
                content: _getStatusText(lichHoc.trangThai),
                contentColor: _getStatusColor(lichHoc.trangThai),
              ),

              // Hình thức
              _buildInfoRow(
                icon: isOnline ? Icons.videocam : Icons.home,
                title: 'Hình thức',
                content: isOnline ? 'Học Online' : 'Học Offline',
                contentColor: isOnline ? Colors.green : Colors.blue,
              ),

              if (lichHoc.isLapLai)
                _buildInfoRow(
                  icon: Icons.repeat,
                  title: 'Lịch lặp lại',
                  content: 'Có',
                  contentColor: Colors.orange,
                ),

              if (isOnline && lichHoc.duongDan != null)
                _buildInfoRow(
                  icon: Icons.link,
                  title: 'Link học',
                  content: lichHoc.duongDan!,
                  isLink: true,
                ),

              const SizedBox(height: 24),

              // Nút đóng
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: contentColor ?? Colors.black87,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        return '${timeParts[0]}:${timeParts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date.split(' ')[0]);
      return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  Color _getStatusColor(String trangThai) {
    switch (trangThai) {
      case 'DaHoc':
        return Colors.green;
      case 'DangDay':
        return Colors.orange;
      case 'SapToi':
        return Colors.blue;
      case 'Huy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String trangThai) {
    switch (trangThai) {
      case 'DaHoc':
        return 'Đã hoàn thành';
      case 'DangDay':
        return 'Đang diễn ra';
      case 'SapToi':
        return 'Sắp diễn ra';
      case 'Huy':
        return 'Đã hủy';
      default:
        return trangThai;
    }
  }
}

/// Dialog cập nhật trạng thái lịch học
class CapNhatTrangThaiDialog extends StatefulWidget {
  final LichHoc lichHoc;
  final Function(String trangThai) onUpdate;

  const CapNhatTrangThaiDialog({
    super.key,
    required this.lichHoc,
    required this.onUpdate,
  });

  @override
  State<CapNhatTrangThaiDialog> createState() =>
      _CapNhatTrangThaiDialogState();
}

class _CapNhatTrangThaiDialogState extends State<CapNhatTrangThaiDialog> {
  late String _selectedStatus;

  final Map<String, String> _statusOptions = {
    'SapToi': 'Sắp tới',
    'DangDay': 'Đang dạy',
    'DaHoc': 'Đã học',
    'Huy': 'Hủy',
  };

  final Map<String, IconData> _statusIcons = {
    'SapToi': Icons.schedule,
    'DangDay': Icons.school,
    'DaHoc': Icons.check_circle,
    'Huy': Icons.cancel,
  };

  final Map<String, Color> _statusColors = {
    'SapToi': Colors.blue,
    'DangDay': Colors.orange,
    'DaHoc': Colors.green,
    'Huy': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.lichHoc.trangThai;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.edit, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cập nhật trạng thái',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Thông tin lịch học
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Lịch học #${widget.lichHoc.lichHocID}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_formatTime(widget.lichHoc.thoiGianBatDau)} - ${_formatTime(widget.lichHoc.thoiGianKetThuc)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách trạng thái
            const Text(
              'Chọn trạng thái mới:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ..._statusOptions.entries.map((entry) {
              final isSelected = _selectedStatus == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedStatus = entry.key;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? _statusColors[entry.key]!.withOpacity(0.1)
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected
                                ? _statusColors[entry.key]!
                                : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusIcons[entry.key],
                          color:
                              isSelected
                                  ? _statusColors[entry.key]
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color:
                                isSelected
                                    ? _statusColors[entry.key]
                                    : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: _statusColors[entry.key],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onUpdate(_selectedStatus);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cập nhật'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        return '${timeParts[0]}:${timeParts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }
}

/// Dialog xóa lịch học
class XoaLichHocDialog extends StatefulWidget {
  final LichHoc lichHoc;
  final Function(bool xoaCaChuoi) onDelete;

  const XoaLichHocDialog({
    super.key,
    required this.lichHoc,
    required this.onDelete,
  });

  @override
  State<XoaLichHocDialog> createState() => _XoaLichHocDialogState();
}

class _XoaLichHocDialogState extends State<XoaLichHocDialog> {
  bool _xoaCaChuoi = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon cảnh báo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Tiêu đề
            const Text(
              'Xác nhận xóa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Thông tin lịch học
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Lịch học #${widget.lichHoc.lichHocID}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTime(widget.lichHoc.thoiGianBatDau)} - ${_formatTime(widget.lichHoc.thoiGianKetThuc)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    _formatDate(widget.lichHoc.ngayHoc),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tùy chọn xóa (nếu là lịch lặp lại)
            if (widget.lichHoc.isLapLai)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange[50],
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _xoaCaChuoi,
                      onChanged: (value) {
                        setState(() {
                          _xoaCaChuoi = value ?? false;
                        });
                      },
                      title: const Text(
                        'Xóa cả chuỗi lịch lặp lại',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Tất cả các buổi học trong chuỗi sẽ bị xóa',
                        style: TextStyle(fontSize: 12),
                      ),
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onDelete(_xoaCaChuoi);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        return '${timeParts[0]}:${timeParts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date.split(' ')[0]);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}
