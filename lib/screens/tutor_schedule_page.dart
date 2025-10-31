// ignore_for_file: depend_on_referenced_packages, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class TutorSchedulePage extends StatefulWidget {
  const TutorSchedulePage({super.key});

  @override
  State<TutorSchedulePage> createState() => _TutorSchedulePageState();
}

class _TutorSchedulePageState extends State<TutorSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  final List<LichHoc> _listLichHoc = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Dữ liệu mẫu cho lịch học trong tháng
    _listLichHoc.addAll([
      LichHoc(
        maLH: 'LH001',
        tenLop: 'Toán lớp 10 - Nâng cao',
        tenGiaSu: 'Nguyễn Văn A',
        monHoc: 'Toán',
        diaDiem: 'Phòng 201, 123 Nguyễn Văn Linh',
        thoiGianBD:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 14:00:00',
        thoiGianKT:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 16:00:00',
        duongDanOnline: 'https://zoom.us/j/123456789',
        thoiGianDay: [],
      ),
      LichHoc(
        maLH: 'LH002',
        tenLop: 'Tiếng Anh giao tiếp',
        tenGiaSu: 'Trần Thị B',
        monHoc: 'Tiếng Anh',
        diaDiem: 'Online',
        thoiGianBD:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)))} 09:00:00',
        thoiGianKT:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)))} 11:00:00',
        duongDanOnline: 'https://zoom.us/j/987654321',
        thoiGianDay: [],
      ),
      LichHoc(
        maLH: 'LH003',
        tenLop: 'Vật lý lớp 11',
        tenGiaSu: 'Lê Văn C',
        monHoc: 'Vật lý',
        diaDiem: '456 Lê Lợi, Quận 1',
        thoiGianBD:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3)))} 16:00:00',
        thoiGianKT:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3)))} 18:00:00',
        duongDanOnline: 'https://zoom.us/j/555555555',
        thoiGianDay: [],
      ),
      LichHoc(
        maLH: 'LH004',
        tenLop: 'Hóa học lớp 12',
        tenGiaSu: 'Phạm Thị D',
        monHoc: 'Hóa học',
        diaDiem: 'Online',
        thoiGianBD:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7)))} 19:00:00',
        thoiGianKT:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7)))} 21:00:00',
        duongDanOnline: 'https://zoom.us/j/111111111',
        thoiGianDay: [],
      ),
      LichHoc(
        maLH: 'LH005',
        tenLop: 'Toán lớp 9',
        tenGiaSu: 'Nguyễn Văn E',
        monHoc: 'Toán',
        diaDiem: '789 Trần Hưng Đạo',
        thoiGianBD:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 10)))} 15:00:00',
        thoiGianKT:
            '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 10)))} 17:00:00',
        duongDanOnline: '',
        thoiGianDay: [],
      ),
    ]);

    setState(() {});
  }

  // Lấy lịch học theo ngày được chọn
  List<LichHoc> _getLichHocTheoNgay(DateTime date) {
    return _listLichHoc.where((lichHoc) {
      final lichDate = DateTime.parse(lichHoc.thoiGianBD.split(' ')[0]);
      return lichDate.year == date.year &&
          lichDate.month == date.month &&
          lichDate.day == date.day;
    }).toList();
  }

  // Kiểm tra ngày có lịch học không
  bool _hasSchedule(DateTime date) {
    return _listLichHoc.any((lichHoc) {
      final lichDate = DateTime.parse(lichHoc.thoiGianBD.split(' ')[0]);
      return lichDate.year == date.year &&
          lichDate.month == date.month &&
          lichDate.day == date.day;
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
    final isOnline = lichHoc.diaDiem.toLowerCase().contains('online');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã LH + Tên lớp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã LH: ${lichHoc.maLH}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isOnline ? Colors.green.shade100 : Colors.blue.shade100,
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
            const SizedBox(height: 8),

            // Tên lớp
            Text(
              lichHoc.tenLop,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Thông tin chi tiết
            _buildInfoRow(Icons.person, 'Giáo sư: ${lichHoc.tenGiaSu}'),
            _buildInfoRow(Icons.book, 'Môn: ${lichHoc.monHoc}'),
            _buildInfoRow(Icons.location_on, 'Địa điểm: ${lichHoc.diaDiem}'),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian: ${_formatTime(lichHoc.thoiGianBD)} - ${_formatTime(lichHoc.thoiGianKT)}',
            ),

            const SizedBox(height: 12),

            // Nút tham gia Zoom (chỉ hiển thị nếu có đường dẫn online)
            if (lichHoc.duongDanOnline.isNotEmpty && isOnline)
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
          ],
        ),
      ),
    );
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

  // Định dạng thời gian từ chuỗi
  String _formatTime(String timeString) {
    final parts = timeString.split(' ');
    if (parts.length >= 2) {
      return parts[1].substring(0, 5); // Lấy HH:MM
    }
    return timeString;
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
                Text('Lớp: ${lichHoc.tenLop}'),
                Text('Giáo sư: ${lichHoc.tenGiaSu}'),
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
        content: Text('Đang mở Zoom cho lớp ${lichHoc.tenLop}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Widget lịch tháng
  Widget _buildMonthCalendar() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final today = DateTime.now();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header tháng năm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
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
            const SizedBox(height: 16),

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
                final hasSchedule = _hasSchedule(date);

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
    final lichHocTheoNgay = _getLichHocTheoNgay(_selectedDate);
    final isCurrentMonth = _selectedDate.month == _currentMonth.month;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LỊCH DẠY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Lịch tháng
          _buildMonthCalendar(),

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
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: lichHocTheoNgay.length,
                      itemBuilder: (context, index) {
                        return _buildLichHocCard(lichHocTheoNgay[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isCurrentMonth = _selectedDate.month == _currentMonth.month;

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

// Model LichHoc
class LichHoc {
  final String maLH;
  final String tenLop;
  final String tenGiaSu;
  final String monHoc;
  final String diaDiem;
  final String thoiGianBD;
  final String thoiGianKT;
  final String duongDanOnline;
  final List<ThoiGianDay> thoiGianDay;

  const LichHoc({
    required this.maLH,
    required this.tenLop,
    required this.tenGiaSu,
    required this.monHoc,
    required this.diaDiem,
    required this.thoiGianBD,
    required this.thoiGianKT,
    required this.duongDanOnline,
    required this.thoiGianDay,
  });
}

class ThoiGianDay {
  final int thu;
  final String gioBatDau;
  final String gioKetThuc;

  const ThoiGianDay({
    required this.thu,
    required this.gioBatDau,
    required this.gioKetThuc,
  });
}
