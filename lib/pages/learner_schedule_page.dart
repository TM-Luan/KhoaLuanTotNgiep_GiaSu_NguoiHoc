// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/schedule_data.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/schedule_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/week_day_selector.dart'; // Thêm widget mới

class LearnerSchedulePage extends StatefulWidget {
  const LearnerSchedulePage({super.key});

  @override
  State<LearnerSchedulePage> createState() => _LearnerSchedulePageState();
}

class _LearnerSchedulePageState extends State<LearnerSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _weekDays;
  late List<LichHoc> _dailySchedules;

  final List<Map<DateTime, LichHoc>> _allSchedulesWithDate = [
    {
      DateTime.now(): const LichHoc(
        maLH: 'LH003',
        tenLop: 'Anh Văn Giao Tiếp Căn Bản',
        tenGiaSu: 'Nguyễn Thị C',
        monHoc: 'Tiếng Anh',
        diaDiem: 'Online (Google Meet)',
        thoiGianBD: '18:00',
        thoiGianKT: '19:30',
        duongDanOnline: 'https://meet.google.com/xyz',
        thoiGianDay: [],
      ),
    },
    {
      DateTime.now().add(const Duration(days: -1)): const LichHoc( 
        maLH: 'LH004',
        tenLop: 'Lập trình Flutter cơ bản',
        tenGiaSu: 'Phạm Đức D',
        monHoc: 'Tin Học',
        diaDiem: 'Phòng học số 5',
        thoiGianBD: '09:00',
        thoiGianKT: '11:00',
        duongDanOnline: '',
        thoiGianDay: [],
      ),
    },
    {
      DateTime.now(): const LichHoc(
        maLH: 'LH005',
        tenLop: 'Hóa 10',
        tenGiaSu: 'Lê Văn F',
        monHoc: 'Hóa Học',
        diaDiem: 'Nhà riêng',
        thoiGianBD: '20:00',
        thoiGianKT: '21:30',
        duongDanOnline: '',
        thoiGianDay: [],
      ),
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeWeek();
    _filterSchedulesByDate(_selectedDate);
  }

  void _initializeWeek() {
    _weekDays = [];
    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday;
    DateTime monday = now.subtract(Duration(days: currentDayOfWeek - 1));

    for (int i = 0; i < 7; i++) {
      _weekDays.add(monday.add(Duration(days: i)));
    }
  }

  void _filterSchedulesByDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _dailySchedules = _allSchedulesWithDate
          .where((map) => map.keys.any((scheduleDate) =>
              scheduleDate.year == _selectedDate.year &&
              scheduleDate.month == _selectedDate.month &&
              scheduleDate.day == _selectedDate.day))
          .map((map) => map.values.first)
          .toList();
    });
  }

  bool _hasSchedule(DateTime date) {
    return _allSchedulesWithDate.any((map) => map.keys.any((scheduleDate) =>
        scheduleDate.year == date.year &&
        scheduleDate.month == date.month &&
        scheduleDate.day == date.day));
  }

  void _joinOnlineClass(String url) {
    if (url.isNotEmpty) {
    }
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 64, color: AppColors.lightGrey),
            SizedBox(height: 16),
            Text(
              'Không có lịch học cho ngày này.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy kiểm tra lịch học ở các ngày khác hoặc đăng ký lớp mới.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String headerText = DateFormat('dd/MM/yyyy').format(_selectedDate) == DateFormat('dd/MM/yyyy').format(DateTime.now())
        ? 'LỊCH HỌC HÔM NAY'
        : 'LỊCH HỌC ${DateFormat('dd/MM/yyyy').format(_selectedDate)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Học Của Tôi'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Xin chào, Minh Luân! 👋', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Hãy cố gắng học tập thật tốt nhé', style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 13)),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tuần này', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_month, size: 18, color: AppColors.white),
                      label: Text(
                        DateFormat('MMMM, yyyy').format(DateTime.now()),
                        style: const TextStyle(fontSize: 13, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                WeekDaySelector(
                  weekDays: _weekDays,
                  selectedDate: _selectedDate,
                  onDateSelected: _filterSchedulesByDate,
                  hasSchedule: _hasSchedule,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatCard(title: 'Tổng buổi học', value: '28', color: Color(0xFFE3F2FD), textColor: Color(0xFF2196F3), icon: '🎓'),
                      _StatCard(title: 'Đã học', value: '20', color: Color(0xFFE8F5E9), textColor: Color(0xFF4CAF50), icon: '✅'),
                      _StatCard(title: 'Sắp tới', value: '8', color: Color(0xFFFFF3E0), textColor: Color(0xFFFF9800), icon: '📅'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    headerText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_dailySchedules.isEmpty)
                    _emptyState()
                  else
                    ..._dailySchedules.map((schedule) => ScheduleCard(
                          schedule: schedule,
                          role: 'learner',
                          onDetails: () {},
                          onPrimaryAction: schedule.duongDanOnline.isNotEmpty
                              ? () => _joinOnlineClass(schedule.duongDanOnline)
                              : null,
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        },
        label: const Text('➕ Đăng ký lớp mới', style: TextStyle(color: AppColors.white)),
        icon: const Icon(Icons.add, color: AppColors.white),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color textColor;
  final String icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 28, color: textColor)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}