// ignore_for_file: depend_on_referenced_packages, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_event.dart';
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
    // Load lịch học của gia sư khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LichHocBloc>().add(const LoadLichHocCuaGiaSuEvent());
    });
  }

  // Lấy lịch học theo ngày được chọn từ BLoC state
  List<LichHoc> _getLichHocTheoNgay(List<LichHoc> allLichHoc, DateTime date) {
    return allLichHoc.where((lichHoc) {
      try {
        final lichDate = DateTime.parse(lichHoc.ngayHoc.split(' ')[0]);
        return lichDate.year == date.year &&
            lichDate.month == date.month &&
            lichDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Kiểm tra ngày có lịch học không
  bool _hasSchedule(List<LichHoc> allLichHoc, DateTime date) {
    return allLichHoc.any((lichHoc) {
      try {
        final lichDate = DateTime.parse(lichHoc.ngayHoc.split(' ')[0]);
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

    // Thêm các ngày từ tháng trước để lấp đầy tuần đầu tiên
    final firstWeekday = first.weekday;
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }

    // Thêm các ngày trong tháng
    for (int i = 0; i < last.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    // Thêm các ngày từ tháng sau để lấp đầy tuần cuối cùng
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
    final isOnline = lichHoc.isOnline;

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
                Text(
                  'Mã LH: ${lichHoc.lichHocID}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
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
            const SizedBox(height: 8),

            // Tên lớp
            Text(
              lichHoc.tenLop ?? 'Lớp học',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Thông tin chi tiết
            _buildInfoRow(
              Icons.person,
              'Học viên: ${lichHoc.tenNguoiHoc ?? 'N/A'}',
            ),
            _buildInfoRow(Icons.book, 'Môn: ${lichHoc.tenMon ?? 'N/A'}'),
            _buildInfoRow(
              Icons.location_on,
              'Hình thức: ${lichHoc.hinhThuc ?? 'N/A'}',
            ),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian: ${lichHoc.formattedTime}',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày: ${lichHoc.formattedDate}',
            ),

            const SizedBox(height: 12),

            // Nút hành động
            if (lichHoc.duongDan != null &&
                lichHoc.duongDan!.isNotEmpty &&
                isOnline)
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

            // Nút cập nhật trạng thái cho gia sư
            if (!lichHoc.isDaHoc)
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
                ],
              ),
          ],
        ),
      ),
    );
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
          Expanded(child: Text(text)),
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
                Text('Lớp: ${lichHoc.tenLop ?? "N/A"}'),
                Text('Học viên: ${lichHoc.tenNguoiHoc ?? "N/A"}'),
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
        content: Text('Đang mở Zoom cho lớp ${lichHoc.tenLop ?? "N/A"}'),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lớp: ${lichHoc.tenLop ?? "N/A"}'),
                const SizedBox(height: 16),
                const Text('Chọn trạng thái mới:'),
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
                  _updateLichHocStatus(lichHoc.lichHocID, 'DangDay');
                },
                child: const Text('Đang dạy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateLichHocStatus(lichHoc.lichHocID, 'DaHoc');
                },
                child: const Text('Đã học'),
              ),
            ],
          ),
    );
  }

  // Cập nhật trạng thái lịch học
  void _updateLichHocStatus(int lichHocId, String trangThai) {
    context.read<LichHocBloc>().add(
      CapNhatTrangThaiLichHocEvent(lichHocId: lichHocId, trangThai: trangThai),
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
            color: Colors.black.withValues(alpha: 0.05),
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
                    fontSize:
                        16, // Sửa lại vì AppTypography.heading3 có thể không tồn tại
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
                final weekday = (index + 1) % 7; // Chủ nhật là 0
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
                              ? AppColors.primaryBlue
                              : isToday
                              ? Colors.blue.shade50
                              : Colors.transparent,
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
        if (state is LichHocErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is LichHocUpdatedState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        List<LichHoc> allLichHoc = [];

        if (state is LichHocLoadedState) {
          allLichHoc = state.danhSachLichHoc;
        } else if (state is LichHocTheoLopLoadedState) {
          allLichHoc = state.danhSachLichHoc;
        }

        final lichHocTheoNgay = _getLichHocTheoNgay(allLichHoc, _selectedDate);
        final isCurrentMonth = _selectedDate.month == _currentMonth.month;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'LỊCH DẠY',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<LichHocBloc>().add(
                    const LoadLichHocCuaGiaSuEvent(),
                  );
                },
              ),
            ],
          ),
          backgroundColor: AppColors.backgroundGrey,
          body:
              state is LichHocLoadingState
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
                            if (!isCurrentMonth)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Tháng ${_selectedDate.month}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
                                  itemBuilder: (context, index) {
                                    return _buildLichHocCard(
                                      lichHocTheoNgay[index],
                                    );
                                  },
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
          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            isCurrentMonth
                ? 'Không có lịch dạy nào\ncho ngày này'
                : 'Không có lịch dạy nào\ncho ngày ${_selectedDate.day} tháng ${_selectedDate.month}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Quay về hôm nay'),
          ),
        ],
      ),
    );
  }
}
