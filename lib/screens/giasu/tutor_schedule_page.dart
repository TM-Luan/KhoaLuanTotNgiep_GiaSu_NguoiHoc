// tutor_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

class TutorSchedulePage extends StatefulWidget {
  const TutorSchedulePage({super.key});

  @override
  State<TutorSchedulePage> createState() => _TutorSchedulePageState();
}

class _TutorSchedulePageState extends State<TutorSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  String? _selectedTrangThai;

  @override
  void initState() {
    super.initState();
    _loadLichHocCuaGiaSu();
  }

  void _loadLichHocCuaGiaSu({
    String? trangThai,
    String? tuNgay,
    String? denNgay,
  }) {
    print('🔄 Loading lịch học gia sư với filter: $trangThai');
    context.read<LichHocBloc>().add(const LoadLichHocCuaGiaSuEvent());
  }

  // Lấy tất cả lịch học (cả gốc và con) để hiển thị
  List<LichHoc> _getAllLichHoc(List<LichHoc> allLichHoc) {
    final result = <LichHoc>[];

    for (final lichHoc in allLichHoc) {
      // Thêm lịch học gốc
      result.add(lichHoc);

      // Thêm lịch học con nếu có
      if (lichHoc.lichHocCon != null && lichHoc.lichHocCon!.isNotEmpty) {
        for (final con in lichHoc.lichHocCon!) {
          result.add(con);

          // Đệ quy nếu có lịch học con của con (nested)
          if (con.lichHocCon != null && con.lichHocCon!.isNotEmpty) {
            result.addAll(con.lichHocCon!);
          }
        }
      }
    }

    print('🔍 _getAllLichHoc: ${allLichHoc.length} -> ${result.length}');
    return result;
  }

  // Lấy lịch học theo ngày được chọn
  List<LichHoc> _getLichHocTheoNgay(List<LichHoc> allLichHoc, DateTime date) {
    final allLichHocFlat = _getAllLichHoc(allLichHoc);
    return allLichHocFlat.where((lichHoc) {
      try {
        if (lichHoc.ngayHoc.isEmpty) return false;

        // Xử lý nhiều định dạng ngày
        String ngayHoc = lichHoc.ngayHoc;

        // Nếu có khoảng trắng, lấy phần đầu (ngày)
        if (ngayHoc.contains(' ')) {
          ngayHoc = ngayHoc.split(' ')[0];
        }

        // Nếu có chữ T (ISO format), thay thế
        if (ngayHoc.contains('T')) {
          ngayHoc = ngayHoc.split('T')[0];
        }

        final lichDate = DateTime.parse(ngayHoc);
        return lichDate.year == date.year &&
            lichDate.month == date.month &&
            lichDate.day == date.day;
      } catch (e) {
        print('❌ Lỗi parse ngày học: ${lichHoc.ngayHoc} - $e');
        return false;
      }
    }).toList();
  }

  // Kiểm tra ngày có lịch học không
  bool _hasSchedule(List<LichHoc> allLichHoc, DateTime date) {
    final allLichHocFlat = _getAllLichHoc(allLichHoc);
    return allLichHocFlat.any((lichHoc) {
      try {
        if (lichHoc.ngayHoc.isEmpty) return false;

        String ngayHoc = lichHoc.ngayHoc;
        if (ngayHoc.contains(' ')) {
          ngayHoc = ngayHoc.split(' ')[0];
        }
        if (ngayHoc.contains('T')) {
          ngayHoc = ngayHoc.split('T')[0];
        }

        final lichDate = DateTime.parse(ngayHoc);
        return lichDate.year == date.year &&
            lichDate.month == date.month &&
            lichDate.day == date.day;
      } catch (e) {
        return false;
      }
    });
  }

  // Lấy danh sách ngày trong tháng
  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    final firstWeekday = first.weekday;
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }

    for (int i = 0; i < last.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    final lastWeekday = last.weekday;
    for (int i = 1; i <= 7 - lastWeekday; i++) {
      days.add(last.add(Duration(days: i)));
    }

    return days;
  }

  // Chuyển đổi số thứ thành tên thứ
  String _getTenThu(int thu) {
    switch (thu) {
      case 1:
        return 'CN';
      case 2:
        return 'T2';
      case 3:
        return 'T3';
      case 4:
        return 'T4';
      case 5:
        return 'T5';
      case 6:
        return 'T6';
      case 7:
        return 'T7';
      default:
        return '';
    }
  }

  // Widget hiển thị card lịch học
  Widget _buildLichHocCard(LichHoc lichHoc) {
    // Xử lý các giá trị có thể null
    final isOnline = (lichHoc.duongDan ?? '').isNotEmpty;
    final isLichHocCon =
        lichHoc.lichHocGocID != null &&
        lichHoc.lichHocGocID != lichHoc.lichHocID;
    final hasChildren = (lichHoc.lichHocCon ?? []).isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã LH + Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã LH: ${lichHoc.lichHocID ?? 'N/A'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (isLichHocCon)
                      Text(
                        'Lịch con của mã ${lichHoc.lichHocGocID}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      'Lớp: ${lichHoc.lopYeuCauID}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Badge trạng thái
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(lichHoc.trangThai),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(lichHoc.trangThai),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge hình thức
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOnline
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOnline ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Thông tin chi tiết - SỬ DỤNG GIÁ TRỊ MẶC ĐỊNH
            _buildInfoRow(
              Icons.access_time,
              'Thời gian: ${_formatTime(lichHoc.thoiGianBatDau)} - ${_formatTime(lichHoc.thoiGianKetThuc)}',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày: ${_formatDate(lichHoc.ngayHoc)}',
            ),

            if (lichHoc.isLapLai && !isLichHocCon)
              _buildInfoRow(
                Icons.repeat,
                'Lịch lặp lại (${hasChildren ? lichHoc.lichHocCon!.length : 0} buổi)',
              ),


            if (isOnline)
              _buildInfoRow(Icons.link, 'Link: ${lichHoc.duongDan ?? ""}'),

            const SizedBox(height: 12),
            // Nút hành động
            if (isOnline)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _joinZoomMeeting(lichHoc);
                  },
                  icon: const Icon(Icons.video_call, size: 20),
                  label: const Text('Tham gia Zoom'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            // Nút cập nhật trạng thái (chỉ cho lịch học chưa kết thúc)
            if (lichHoc.trangThai != 'DaHoc' && lichHoc.trangThai != 'Huy')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showUpdateStatusDialog(lichHoc);
                      },
                      child: const Text('Cập nhật trạng thái'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showDeleteDialog(lichHoc);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
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

  // Định dạng thời gian
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

  // Định dạng ngày
  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date.split(' ')[0]);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  // Màu sắc cho trạng thái
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

  // Văn bản cho trạng thái
  String _getStatusText(String trangThai) {
    switch (trangThai) {
      case 'DaHoc':
        return 'ĐÃ HỌC';
      case 'DangDay':
        return 'ĐANG DẠY';
      case 'SapToi':
        return 'SẮP TỚI';
      case 'Huy':
        return 'ĐÃ HỦY';
      default:
        return trangThai;
    }
  }

  // Widget hiển thị thông tin hàng
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // Hàm xử lý tham gia Zoom
  void _joinZoomMeeting(LichHoc lichHoc) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tham gia Zoom'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Link: ${lichHoc.duongDan}'),
                const SizedBox(height: 16),
                const Text('Bạn có muốn tham gia buổi học ngay bây giờ?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showZoomJoinSuccess(lichHoc);
                },
                child: const Text('Tham gia ngay'),
              ),
            ],
          ),
    );
  }

  void _showZoomJoinSuccess(LichHoc lichHoc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở Zoom: ${lichHoc.duongDan}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Hiển thị dialog cập nhật trạng thái
  void _showUpdateStatusDialog(LichHoc lichHoc) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cập nhật trạng thái'),
            content: const Text('Chọn trạng thái mới:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateLichHocStatus(lichHoc, 'DangDay');
                },
                child: const Text('Đang dạy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateLichHocStatus(lichHoc, 'DaHoc');
                },
                child: const Text('Đã học'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateLichHocStatus(lichHoc, 'Huy');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hủy'),
              ),
            ],
          ),
    );
  }

  // Hiển thị dialog xóa lịch học
  void _showDeleteDialog(LichHoc lichHoc) {
    final isLichHocGoc =
        lichHoc.lichHocGocID == null ||
        lichHoc.lichHocGocID == lichHoc.lichHocID;
    final hasChildren =
        lichHoc.lichHocCon != null && lichHoc.lichHocCon!.isNotEmpty;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa lịch học'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bạn có chắc muốn xóa lịch học này?'),
                if (isLichHocGoc && hasChildren && lichHoc.isLapLai) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Lịch học này có các buổi lặp lại. Bạn muốn xóa:',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              if (isLichHocGoc && hasChildren && lichHoc.isLapLai)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteLichHoc(lichHoc, xoaCaChuoi: false);
                  },
                  child: const Text('Chỉ buổi này'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteLichHoc(
                    lichHoc,
                    xoaCaChuoi: isLichHocGoc && hasChildren && lichHoc.isLapLai,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isLichHocGoc && hasChildren && lichHoc.isLapLai
                      ? 'Cả chuỗi'
                      : 'Xóa',
                ),
              ),
            ],
          ),
    );
  }

  // Cập nhật trạng thái lịch học
  void _updateLichHocStatus(LichHoc lichHoc, String trangThai) {
    if (lichHoc.lichHocID == null) return;

    context.read<LichHocBloc>().add(
      CapNhatLichHocEvent(lichHoc.lichHocID!, {'TrangThai': trangThai}),
    );
  }

  // Xóa lịch học
  void _deleteLichHoc(LichHoc lichHoc, {bool xoaCaChuoi = false}) {
    if (lichHoc.lichHocID == null) return;

    context.read<LichHocBloc>().add(
      XoaLichHocEvent(lichHoc.lichHocID!, xoaCaChuoi: xoaCaChuoi),
    );
  }

  // Hiển thị dialog filter
  void _showFilterDialog() {
    String? tempTrangThai = _selectedTrangThai;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Lọc lịch học'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: tempTrangThai,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Tất cả trạng thái'),
                        ),
                        const DropdownMenuItem(
                          value: 'SapToi',
                          child: Text('Sắp tới'),
                        ),
                        const DropdownMenuItem(
                          value: 'DangDay',
                          child: Text('Đang dạy'),
                        ),
                        const DropdownMenuItem(
                          value: 'DaHoc',
                          child: Text('Đã học'),
                        ),
                        const DropdownMenuItem(
                          value: 'Huy',
                          child: Text('Đã hủy'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tempTrangThai = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedTrangThai = tempTrangThai;
                      });
                      _loadLichHocCuaGiaSu(trangThai: _selectedTrangThai);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Widget lịch tháng
  Widget _buildMonthCalendar(List<LichHoc> allLichHoc) {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final today = DateTime.now();

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Header tháng năm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM, yyyy').format(_currentMonth).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Header các ngày trong tuần
            Row(
              children: List.generate(7, (index) {
                final weekday = (index + 1) % 7;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _getTenThu(weekday == 0 ? 7 : weekday),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Lưới ngày trong tháng
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                final date = daysInMonth[index];
                final isCurrentMonth = date.month == _currentMonth.month;
                final isToday =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isSelected =
                    date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final hasSchedule = _hasSchedule(allLichHoc, date);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary
                              : (isToday
                                  ? Colors.blue.shade50
                                  : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          isToday && !isSelected
                              ? Border.all(color: Colors.blue)
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isCurrentMonth
                                    ? (isSelected ? Colors.white : Colors.black)
                                    : Colors.grey,
                          ),
                        ),
                        if (hasSchedule && isCurrentMonth)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LichHocBloc, LichHocState>(
      listener: (context, state) {
        if (state is LichHocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is CapNhatLichHocSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadLichHocCuaGiaSu();
        } else if (state is XoaLichHocSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadLichHocCuaGiaSu();
        } else if (state is TaoLichHocSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadLichHocCuaGiaSu();
        }
      },
      builder: (context, state) {
        List<LichHoc> allLichHoc = [];

        if (state is LichHocCuaGiaSuLoaded) {
          allLichHoc = state.danhSachLichHoc;
          print('🎯 UI: Nhận được ${allLichHoc.length} lịch học');

          // Debug chi tiết từng lịch học
          for (var i = 0; i < allLichHoc.length; i++) {
            final lich = allLichHoc[i];
            print(
              '📅 Lịch $i: ID=${lich.lichHocID}, Ngày=${lich.ngayHoc}, Trạng thái=${lich.trangThai}, Lặp lại=${lich.isLapLai}',
            );
          }

          // Debug lịch học con
          final allLichHocFlat = _getAllLichHoc(allLichHoc);
          print('📊 Tổng số buổi (cả gốc và con): ${allLichHocFlat.length}');
        }

        final lichHocTheoNgay = _getLichHocTheoNgay(allLichHoc, _selectedDate);
        final isCurrentMonth = _selectedDate.month == _currentMonth.month;

        print(
          '📅 Ngày chọn: $_selectedDate, Số buổi: ${lichHocTheoNgay.length}',
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'LỊCH DẠY CỦA TÔI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
                tooltip: 'Lọc lịch học',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadLichHocCuaGiaSu(),
                tooltip: 'Tải lại',
              ),
            ],
          ),
          backgroundColor: AppColors.backgroundGrey ?? Colors.grey.shade100,
          body:
              state is LichHocLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      // Lịch tháng
                      _buildMonthCalendar(allLichHoc),

                      // Thông tin ngày được chọn
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'EEEE, dd/MM/yyyy',
                              ).format(_selectedDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (lichHocTheoNgay.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${lichHocTheoNgay.length} buổi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Danh sách lịch học
                      Expanded(
                        child:
                            lichHocTheoNgay.isEmpty
                                ? _buildEmptyState(isCurrentMonth)
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: lichHocTheoNgay.length,
                                  itemBuilder:
                                      (context, index) => _buildLichHocCard(
                                        lichHocTheoNgay[index],
                                      ),
                                ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isCurrentMonth) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isCurrentMonth
                ? 'Không có lịch dạy nào\ncho ngày này'
                : 'Không có lịch dạy nào\ncho ngày ${_selectedDate.day} tháng ${_selectedDate.month}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _currentMonth = DateTime.now();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Quay về hôm nay'),
          ),
        ],
      ),
    );
  }
}
