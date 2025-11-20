// file: tutor_schedule_page.dart

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/lich_hoc_dialogs.dart';

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
    _loadLichHocCalendar();
  }

  void _loadLichHocCalendar() {
    context.read<LichHocBloc>().add(
      LoadLichHocCalendar(
        thang: _currentMonth.month,
        nam: _currentMonth.year,
        ngayChon: _selectedDate,
        isGiaSu: true,
      ),
    );
  }

  void _loadNewMonth() {
    final newSelectedDate = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    setState(() {
      _selectedDate = newSelectedDate;
    });

    context.read<LichHocBloc>().add(
      LoadLichHocCalendar(
        thang: _currentMonth.month,
        nam: _currentMonth.year,
        ngayChon: newSelectedDate,
        isGiaSu: true,
      ),
    );
  }

  void _changeSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    context.read<LichHocBloc>().add(
      ChangeLichHocNgay(ngayChon: newDate, isGiaSu: true),
    );
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    final firstWeekday = first.weekday;
    for (int i = (firstWeekday == 7 ? 0 : firstWeekday); i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }

    for (int i = 0; i < last.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    final lastWeekday = last.weekday;
    if (lastWeekday != 7) {
      for (int i = 1; i <= 7 - lastWeekday; i++) {
        days.add(last.add(Duration(days: i)));
      }
    }

    return days;
  }

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
    // [LOGIC MỚI]
    // 1. Quyết định HÌNH THỨC (tag) dựa trên LỚP HỌC
    final bool isOnlineClass = (lichHoc.lopHoc?.hinhThuc == 'Online');

    // 2. Quyết định HÀNH ĐỘNG (nút "Tham gia") dựa trên CÓ LINK hay không
    final bool hasLink = (lichHoc.duongDan ?? '').isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã Lịch học: ${lichHoc.lichHocID}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Mã Lớp: ${lichHoc.lopYeuCauID}',
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOnlineClass
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOnlineClass ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(
                          color: isOnlineClass ? Colors.green : Colors.blue,
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
            _buildInfoRow(
              Icons.access_time,
              'Thời gian: ${_formatTime(lichHoc.thoiGianBatDau)} - ${_formatTime(lichHoc.thoiGianKetThuc)}',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày: ${_formatDate(lichHoc.ngayHoc)}',
            ),
            if (lichHoc.lopHoc?.tenNguoiHoc != null)
              _buildInfoRow(
                Icons.person,
                'Tên người học: ${lichHoc.lopHoc!.tenNguoiHoc}',
              ),
            if (isOnlineClass)
              _buildInfoRow(
                Icons.link,
                'Link: ${lichHoc.duongDan ?? "Chưa có link"}',
              )
            else if (lichHoc.lopHoc?.diaChi != null &&
                lichHoc.lopHoc!.diaChi!.isNotEmpty)
              _buildInfoRow(
                Icons.location_on,
                'Địa chỉ: ${lichHoc.lopHoc!.diaChi}',
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Nút Chi tiết
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => ChiTietLichHocDialog(
                              lichHoc: lichHoc,
                              isGiaSu: true,
                            ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Chi tiết'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (hasLink) const SizedBox(width: 8),
                // Nút Cập nhật
                if (lichHoc.trangThai != 'DaHoc' && lichHoc.trangThai != 'Huy')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => SuaLichHocDialog(
                                lichHoc: lichHoc,
                                isOnlineClass: isOnlineClass,
                                onUpdate: (trangThai, duongDan) {
                                  context.read<LichHocBloc>().add(
                                    UpdateLichHoc(
                                      lichHocId: lichHoc.lichHocID,
                                      trangThai: trangThai,
                                      duongDan: duongDan,
                                    ),
                                  );
                                },
                              ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Cập nhật'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),

                // Nút Tham gia
                if (hasLink)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _joinMeeting(lichHoc);
                      },
                      icon: const Icon(Icons.video_call, size: 16),
                      label: const Text('Tham gia'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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

  Future<void> _launchLink(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở link: $urlString')),
        );
      }
    }
  }

  void _joinMeeting(LichHoc lichHoc) {
    if (lichHoc.duongDan != null && lichHoc.duongDan!.isNotEmpty) {
      _launchLink(lichHoc.duongDan!);
    }
  }

  Widget _buildMonthCalendar(LichHocCalendarLoaded state) {
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
                      _loadNewMonth();
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
                      _loadNewMonth();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: List.generate(7, (index) {
                final weekday = index + 1;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _getTenThu(weekday),
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

                final dateString = DateFormat('yyyy-MM-dd').format(date);
                final hasSchedule = state.ngayCoLich.contains(dateString);

                return GestureDetector(
                  onTap: () {
                    if (isCurrentMonth) {
                      _changeSelectedDate(date);
                    }
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
                                    : Colors.grey.shade400,
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
            'Không có lịch dạy nào\ncho ngày này',
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
              _loadLichHocCalendar();
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
      listenWhen: (previous, current) {
        return current is LichHocError ||
            current is LichHocUpdated ||
            current is LichHocDeleted;
      },
      listener: (context, state) {
        if (state is LichHocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is LichHocUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật lịch học thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _changeSelectedDate(_selectedDate);
        } else if (state is LichHocDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadLichHocCalendar();
        }
      },
      buildWhen: (previous, current) {
        return current is LichHocLoading ||
            current is LichHocCalendarLoaded ||
            current is LichHocError ||
            current is LichHocInitial;
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
                onPressed: _loadLichHocCalendar,
                tooltip: 'Tải lại',
              ),
            ],
          ),
          backgroundColor: AppColors.backgroundGrey,
          body:
              (state is LichHocLoading)
                  ? const Center(child: CircularProgressIndicator())
                  : (state is LichHocCalendarLoaded)
                  ? _buildScheduleContent(state)
                  : (state is LichHocError)
                  ? _buildErrorState()
                  : const Center(child: Text('Đang tải...')),
        );
      },
    );
  }

  Widget _buildScheduleContent(LichHocCalendarLoaded state) {
    final lichHocTheoNgay = state.lichHocNgayChon;
    final isCurrentMonth = _selectedDate.month == _currentMonth.month;

    return Column(
      children: [
        _buildMonthCalendar(state),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selectedDate),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (lichHocTheoNgay.isNotEmpty && !state.isLoadingDetails)
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
        Expanded(
          child:
              state.isLoadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : lichHocTheoNgay.isEmpty
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
            onPressed: _loadLichHocCalendar,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
