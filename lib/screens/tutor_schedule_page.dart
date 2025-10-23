// ignore_for_file: depend_on_referenced_packages, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/schedule_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/week_day_selector.dart'; // Thêm widget mới

class TutorSchedulePage extends StatefulWidget {
  const TutorSchedulePage({super.key});

  @override
  State<TutorSchedulePage> createState() => _TutorSchedulePageState();
}

class _TutorSchedulePageState extends State<TutorSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _weekDays;
  late List<LichHoc> _dailySchedules;

  final List<Map<DateTime, LichHoc>> _allSchedulesWithDate = [
    {
      DateTime.now(): const LichHoc(
        maLH: 'LH001',
        tenLop: 'Toán 12 Nâng Cao',
        tenGiaSu: 'Trần Văn B',
        monHoc: 'Toán',
        diaDiem: 'Online (Zoom)',
        thoiGianBD: '08:00',
        thoiGianKT: '10:00',
        duongDanOnline: 'https://zoom.us/j/123456',
        thoiGianDay: [],
      ),
    },
    {
      DateTime.now(): const LichHoc(
        maLH: 'LH002',
        tenLop: 'Anh văn Giao tiếp',
        tenGiaSu: 'Trần Văn B',
        monHoc: 'Tiếng Anh',
        diaDiem: 'Tầng 2, 123 Đường ABC',
        thoiGianBD: '14:00',
        thoiGianKT: '16:00',
        duongDanOnline: '',
        thoiGianDay: [],
      ),
    },
    {
      DateTime.now().add(const Duration(days: 1)): const LichHoc(
        // Ngày mai
        maLH: 'LH003',
        tenLop: 'Ôn thi THPT QG - Lý',
        tenGiaSu: 'Trần Văn B',
        monHoc: 'Vật Lý',
        diaDiem: 'Online (Meet)',
        thoiGianBD: '19:00',
        thoiGianKT: '21:00',
        duongDanOnline: 'https://meet.google.com/xyz',
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
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 64, color: AppColors.lightGrey),
            SizedBox(height: 16),
            Text(
              'Không có lịch dạy cho ngày này.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy thêm lịch dạy hoặc kiểm tra lại ngày khác.',
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
    String headerText =
        DateFormat('dd/MM/yyyy').format(_selectedDate) ==
                DateFormat('dd/MM/yyyy').format(DateTime.now())
            ? 'LỊCH DẠY HÔM NAY'
            : 'LỊCH DẠY ${DateFormat('dd/MM/yyyy').format(_selectedDate)}';

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tuần này',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: AppColors.white,
                      ),
                      label: Text(
                        DateFormat('MMMM, yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.white,
                        ),
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
                      _StatCard(
                        title: 'Tổng buổi dạy',
                        value: '24',
                        color: Color(0xFFE3F2FD),
                        textColor: Color(0xFF2196F3),
                        icon: '🎓',
                      ),
                      _StatCard(
                        title: 'Hoàn thành',
                        value: '18',
                        color: Color(0xFFE8F5E9),
                        textColor: Color(0xFF4CAF50),
                        icon: '✅',
                      ),
                      _StatCard(
                        title: 'Sắp tới',
                        value: '6',
                        color: Color(0xFFFFF3E0),
                        textColor: Color(0xFFFF9800),
                        icon: '⏰',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    headerText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_dailySchedules.isEmpty)
                    _emptyState()
                  else
                    ..._dailySchedules.map(
                      (schedule) => ScheduleCard(
                        schedule: schedule,
                        role: 'tutor',
                        onDetails: () {},
                        onPrimaryAction: () {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text(
          'Thêm Lịch Dạy Mới',
          style: TextStyle(color: AppColors.white),
        ),
        icon: const Icon(Icons.add, color: AppColors.white),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// =================================================
// HELPER WIDGETS (Cần phải định nghĩa hoặc import)
// =================================================

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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
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
