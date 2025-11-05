import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLichHocTheoThang();
  }

  void _loadLichHocTheoThang() {
    print(
      '🔄 Loading lịch học tháng ${_currentMonth.month}/${_currentMonth.year}',
    );
    context.read<LichHocBloc>().add(
      GetLichHocTheoThangGiaSu(
        thang: _currentMonth.month,
        nam: _currentMonth.year,
      ),
    );
  }

  // Lấy lịch học theo ngày được chọn
  List<LichHoc> _getLichHocTheoNgay(
    LichHocTheoThangResponse response,
    DateTime date,
  ) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return response.lichHocTheoNgay[dateString] ?? [];
  }

  // Kiểm tra ngày có lịch học không
  bool _hasSchedule(LichHocTheoThangResponse response, DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return response.lichHocTheoNgay.containsKey(dateString);
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
    final isOnline = (lichHoc.duongDan ?? '').isNotEmpty;

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
                      'Mã LH: ${lichHoc.lichHocID}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Lớp: ${lichHoc.lopYeuCauID}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    if (lichHoc.lopHoc?.tenMon != null)
                      Text(
                        'Môn: ${lichHoc.lopHoc!.tenMon}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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

            // Thông tin chi tiết
            _buildInfoRow(
              Icons.access_time,
              'Thời gian: ${_formatTime(lichHoc.thoiGianBatDau)} - ${_formatTime(lichHoc.thoiGianKetThuc)}',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày: ${_formatDate(lichHoc.ngayHoc)}',
            ),

            if (lichHoc.isLapLai) _buildInfoRow(Icons.repeat, 'Lịch lặp lại'),

            if (lichHoc.lopHoc?.tenNguoiHoc != null)
              _buildInfoRow(
                Icons.person,
                'Học sinh: ${lichHoc.lopHoc!.tenNguoiHoc}',
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
                if (isLichHocGoc && lichHoc.isLapLai) ...[
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
              if (isLichHocGoc && lichHoc.isLapLai)
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
                    xoaCaChuoi: isLichHocGoc && lichHoc.isLapLai,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isLichHocGoc && lichHoc.isLapLai ? 'Cả chuỗi' : 'Xóa',
                ),
              ),
            ],
          ),
    );
  }

  // Cập nhật trạng thái lịch học
  void _updateLichHocStatus(LichHoc lichHoc, String trangThai) {
    context.read<LichHocBloc>().add(
      UpdateLichHoc(lichHocId: lichHoc.lichHocID, trangThai: trangThai),
    );
  }

  // Xóa lịch học
  void _deleteLichHoc(LichHoc lichHoc, {bool xoaCaChuoi = false}) {
    context.read<LichHocBloc>().add(
      DeleteLichHoc(lichHocId: lichHoc.lichHocID, xoaCaChuoi: xoaCaChuoi),
    );
  }

  // Widget lịch tháng
  Widget _buildMonthCalendar(LichHocTheoThangResponse response) {
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
                      _loadLichHocTheoThang();
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
                      _loadLichHocTheoThang();
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
                final hasSchedule = _hasSchedule(response, date);

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
              _loadLichHocTheoThang();
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LichHocBloc, LichHocState>(
      listener: (context, state) {
        if (state is LichHocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is LichHocUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật trạng thái thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadLichHocTheoThang();
        } else if (state is LichHocDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadLichHocTheoThang();
        }
      },
      builder: (context, state) {
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
                icon: const Icon(Icons.refresh),
                onPressed: _loadLichHocTheoThang,
                tooltip: 'Tải lại',
              ),
            ],
          ),
          backgroundColor: AppColors.backgroundGrey ?? Colors.grey.shade100,
          body:
              state is LichHocLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is LichHocTheoThangLoaded
                  ? _buildScheduleContent(state.response)
                  : state is LichHocError
                  ? _buildErrorState()
                  : const SizedBox(),
        );
      },
    );
  }

  Widget _buildScheduleContent(LichHocTheoThangResponse response) {
    final lichHocTheoNgay = _getLichHocTheoNgay(response, _selectedDate);
    final isCurrentMonth = _selectedDate.month == _currentMonth.month;

    return Column(
      children: [
        // Lịch tháng
        _buildMonthCalendar(response),

        // Thông tin ngày được chọn
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate),
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

        // Thống kê tháng
        _buildThongKeThang(response.thongKeThang),

        const SizedBox(height: 16),

        // Danh sách lịch học
        Expanded(
          child:
              lichHocTheoNgay.isEmpty
                  ? _buildEmptyState(isCurrentMonth)
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lichHocTheoNgay.length,
                    itemBuilder:
                        (context, index) =>
                            _buildLichHocCard(lichHocTheoNgay[index]),
                  ),
        ),
      ],
    );
  }

  Widget _buildThongKeThang(ThongKeThang thongKe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildThongKeItem('Tổng', thongKe.tongSoBuoi.toString(), Colors.blue),
          _buildThongKeItem(
            'Sắp tới',
            thongKe.sapToi.toString(),
            Colors.orange,
          ),
          _buildThongKeItem('Đã học', thongKe.daHoc.toString(), Colors.green),
          _buildThongKeItem('Đã hủy', thongKe.huy.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildThongKeItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Có lỗi xảy ra khi tải lịch học',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadLichHocTheoThang,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
