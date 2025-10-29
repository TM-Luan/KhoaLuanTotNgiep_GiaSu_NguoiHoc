// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/schedule_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/week_day_selector.dart';

class LearnerSchedulePage extends StatefulWidget {
  const LearnerSchedulePage({super.key});

  @override
  State<LearnerSchedulePage> createState() => _LearnerSchedulePageState();
}

class _LearnerSchedulePageState extends State<LearnerSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _weekDays;
  late List<LichHoc> _dailySchedules;

  @override
  void initState() {
    super.initState();
    _initializeWeek();
    _filterSchedulesByDate(_selectedDate);
  }

  void _initializeWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  void _filterSchedulesByDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _dailySchedules =
          _allSchedulesWithDate
              .where(
                (map) => map.keys.any(
                  (scheduleDate) =>
                      scheduleDate.year == _selectedDate.year &&
                      scheduleDate.month == _selectedDate.month &&
                      scheduleDate.day == _selectedDate.day,
                ),
              )
              .map((map) => map.values.first)
              .toList();
    });
  }

  bool _hasSchedule(DateTime date) {
    return _allSchedulesWithDate.any(
      (map) => map.keys.any(
        (scheduleDate) =>
            scheduleDate.year == date.year &&
            scheduleDate.month == date.month &&
            scheduleDate.day == date.day,
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 64, color: AppColors.lightGrey),
            SizedBox(height: 16),
            Text(
              'Không có lịch học cho ngày này',
              style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDate.isSameDate(DateTime.now());
    final headerText =
        isToday
            ? 'LỊCH HỌC HÔM NAY'
            : 'LỊCH HỌC ${DateFormat('dd/MM/yyyy').format(_selectedDate)}';

    return Scaffold(
      body: Column(
        children: [
          // Header với tuần
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withOpacity(0.8),
                ],
              ),
            ),
            child: WeekDaySelector(
              weekDays: _weekDays,
              selectedDate: _selectedDate,
              onDateSelected: _filterSchedulesByDate,
              hasSchedule: _hasSchedule,
            ),
          ),

          // Thống kê
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                _StatItem(title: 'Tổng', value: '28', color: Color(0xFF2196F3)),
                SizedBox(width: 8),
                _StatItem(
                  title: 'Đã học',
                  value: '20',
                  color: Color(0xFF4CAF50),
                ),
                SizedBox(width: 8),
                _StatItem(
                  title: 'Sắp tới',
                  value: '8',
                  color: Color(0xFFFF9800),
                ),
              ],
            ),
          ),

          // Danh sách lịch học
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child:
                        _dailySchedules.isEmpty
                            ? _emptyState()
                            : ListView.separated(
                              itemCount: _dailySchedules.length,
                              separatorBuilder:
                                  (context, index) =>
                                      const SizedBox(height: 12),
                              itemBuilder:
                                  (context, index) => ScheduleCard(
                                    schedule: _dailySchedules[index],
                                    role: 'learner',
                                    onDetails: () {},
                                    onPrimaryAction:
                                        _dailySchedules[index]
                                                .duongDanOnline
                                                .isNotEmpty
                                            ? () {}
                                            : null,
                                  ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Widget thống kê đơn giản
class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
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
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension để so sánh ngày
extension DateUtils on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

// Dữ liệu mẫu
final List<Map<DateTime, LichHoc>> _allSchedulesWithDate = [
  {
    DateTime.now(): const LichHoc(
      maLH: 'LH003',
      tenLop: 'Anh Văn Giao Tiếp',
      tenGiaSu: 'Nguyễn Thị C',
      monHoc: 'Tiếng Anh',
      diaDiem: 'Online',
      thoiGianBD: '18:00',
      thoiGianKT: '19:30',
      duongDanOnline: 'https://meet.google.com/xyz',
      thoiGianDay: [],
    ),
  },
  {
    DateTime.now().add(const Duration(days: 1)): const LichHoc(
      maLH: 'LH004',
      tenLop: 'Lập trình Flutter',
      tenGiaSu: 'Phạm Đức D',
      monHoc: 'Tin Học',
      diaDiem: 'Phòng học số 5',
      thoiGianBD: '09:00',
      thoiGianKT: '11:00',
      duongDanOnline: '',
      thoiGianDay: [],
    ),
  },
];
