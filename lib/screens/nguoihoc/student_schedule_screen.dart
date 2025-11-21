import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/lich_hoc_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnerSchedulePage extends StatefulWidget {
  const LearnerSchedulePage({super.key});

  @override
  State<LearnerSchedulePage> createState() => _LearnerSchedulePageState();
}

class _LearnerSchedulePageState extends State<LearnerSchedulePage> {
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
        isGiaSu: false,
      ),
    );
  }

  void _loadNewMonth() {
    final newSelectedDate = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    setState(() => _selectedDate = newSelectedDate);
    context.read<LichHocBloc>().add(
      LoadLichHocCalendar(
        thang: _currentMonth.month,
        nam: _currentMonth.year,
        ngayChon: newSelectedDate,
        isGiaSu: false,
      ),
    );
  }

  void _changeSelectedDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    context.read<LichHocBloc>().add(
      ChangeLichHocNgay(ngayChon: newDate, isGiaSu: false),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lịch học',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _currentMonth = DateTime.now();
              });
              _loadLichHocCalendar();
            },
            tooltip: 'Hôm nay',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: BlocConsumer<LichHocBloc, LichHocState>(
        listener: (context, state) {
          if (state is LichHocError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LichHocLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LichHocError) return _buildErrorState();
          if (state is LichHocCalendarLoaded) {
            return _buildScheduleContent(state);
          }
          return const Center(child: Text('Đang tải...'));
        },
      ),
    );
  }

  Widget _buildScheduleContent(LichHocCalendarLoaded state) {
    final lichHocTheoNgay = state.lichHocNgayChon;
    return Column(
      children: [
        _buildMonthCalendar(state),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.grey.shade50,
          child: Text(
            DateFormat(
              'EEEE, d MMMM',
              'vi',
            ).format(_selectedDate).toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 1,
            ),
          ),
        ),

        Expanded(
          child:
              state.isLoadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : lichHocTheoNgay.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: lichHocTheoNgay.length,
                    itemBuilder:
                        (context, index) =>
                            _buildTimelineItem(lichHocTheoNgay[index]),
                  ),
        ),
      ],
    );
  }

  // --- CALENDAR WIDGET CLEAN ---
  Widget _buildMonthCalendar(LichHocCalendarLoaded state) {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final today = DateTime.now();
    const weekDays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      () => setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        );
                        _loadNewMonth();
                      }),
                ),
                Text(
                  DateFormat(
                    'MMMM yyyy',
                    'vi',
                  ).format(_currentMonth).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      () => setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        );
                        _loadNewMonth();
                      }),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                weekDays
                    .map(
                      (e) => Text(
                        e,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final date = daysInMonth[index];
              final isCurrentMonth = date.month == _currentMonth.month;
              final isSelected =
                  date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final dateString = DateFormat('yyyy-MM-dd').format(date);
              final hasSchedule = state.ngayCoLich.contains(dateString);

              if (!isCurrentMonth) return const SizedBox();

              return GestureDetector(
                onTap: () => _changeSelectedDate(date),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primary
                                : (isToday
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : (isToday
                                      ? AppColors.primary
                                      : Colors.black87),
                          fontWeight:
                              isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasSchedule)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TIMELINE ITEM CLEAN ---
  Widget _buildTimelineItem(LichHoc lichHoc) {
    final isOnline = (lichHoc.duongDan ?? '').isNotEmpty;
    final startTime = _formatTime(lichHoc.thoiGianBatDau);
    final endTime = _formatTime(lichHoc.thoiGianKetThuc);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Text(
                  startTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  endTime,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          // Timeline Line
          VerticalDivider(width: 0, thickness: 1, color: Colors.grey.shade200),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(lichHoc.trangThai),
                      if (isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 12,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lichHoc.lopHoc?.tenMon ?? 'Môn học',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'GV: ${lichHoc.lopHoc?.tenGiaSu ?? "---"}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              () => showDialog(
                                context: context,
                                builder:
                                    (_) => ChiTietLichHocDialog(
                                      lichHoc: lichHoc,
                                      isGiaSu: false,
                                    ),
                              ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text(
                            'Chi tiết',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isOnline)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _launchLink(lichHoc.duongDan!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text(
                              'Vào học',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String trangThai) {
    Color color;
    String text;
    switch (trangThai) {
      case 'DaHoc':
        color = Colors.green;
        text = 'Đã học';
        break;
      case 'DangDay':
        color = Colors.orange;
        text = 'Đang diễn ra';
        break;
      case 'Huy':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = AppColors.primary;
        text = 'Sắp tới';
    }
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Không có lịch học',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: TextButton(
        onPressed: _loadLichHocCalendar,
        child: const Text("Thử lại"),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      return time.split(':').sublist(0, 2).join(':');
    } catch (e) {
      return time;
    }
  }

  Future<void> _launchLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi link: $urlString')));
      }
    }
  }
}
