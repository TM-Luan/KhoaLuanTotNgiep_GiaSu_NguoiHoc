import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
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

  void _changeSelectedDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    context.read<LichHocBloc>().add(
      ChangeLichHocNgay(ngayChon: newDate, isGiaSu: true),
    );
  }

  // Helper tạo danh sách ngày trong tháng để vẽ lịch
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
          'Lịch dạy',
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
            icon: const Icon(Icons.refresh, color: Colors.black87),
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

          // [SỬA LỖI TẠI ĐÂY]: Thêm state is LichHocCreated
          if (state is LichHocUpdated ||
              state is LichHocDeleted ||
              state is LichHocCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thành công'), // Hoặc thông báo cụ thể hơn
                backgroundColor: Colors.green,
              ),
            );

            // Bắt buộc gọi hàm này để tải lại dữ liệu và chuyển state về Loaded
            _loadLichHocCalendar();
          }
        },
        builder: (context, state) {
          if (state is LichHocLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Nếu lỡ state đang là Created/Updated/Deleted mà chưa kịp chuyển,
          // ta vẫn có thể hiện loading hoặc giữ giao diện cũ nếu muốn.
          // Nhưng logic listener ở trên sẽ xử lý việc chuyển state rất nhanh.

          if (state is LichHocCalendarLoaded) return _buildBody(state);

          if (state is LichHocError) return _buildError();

          // Dòng này là nguyên nhân hiện "Đang tải..."
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBody(LichHocCalendarLoaded state) {
    return Column(
      children: [
        _buildCalendar(state),
        const Divider(height: 1),
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
                  : state.lichHocNgayChon.isEmpty
                  ? _buildEmpty()
                  : _buildTimelineList(state.lichHocNgayChon),
        ),
      ],
    );
  }

  Widget _buildCalendar(LichHocCalendarLoaded state) {
    final days = _getDaysInMonth(_currentMonth);
    final today = DateTime.now();
    const weekDays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
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
                        _loadLichHocCalendar();
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
                        _loadLichHocCalendar();
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
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              if (date.month != _currentMonth.month) return const SizedBox();

              final isSelected =
                  date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              // Kiểm tra xem ngày này có lịch hay không để hiện dấu chấm
              final hasSchedule = state.ngayCoLich.contains(
                DateFormat('yyyy-MM-dd').format(date),
              );

              return GestureDetector(
                onTap: () => _changeSelectedDate(date),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primary
                                : (isToday
                                    ? AppColors.primary.withOpacity(0.1)
                                    : null),
                        shape: BoxShape.circle,
                      ),
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
                              (isSelected || isToday)
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

  Widget _buildTimelineList(List<LichHoc> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildTimelineItem(list[index]),
    );
  }

  Widget _buildTimelineItem(LichHoc item) {
    final isOnline = item.lopHoc?.hinhThuc == 'Online';
    final hasLink = (item.duongDan ?? '').isNotEmpty;
    final startTime = _formatTime(item.thoiGianBatDau);
    final endTime = _formatTime(item.thoiGianKetThuc);
    final String diaChi = item.lopHoc?.diaChi ?? 'Chưa cập nhật địa chỉ';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              children: [
                const SizedBox(height: 16),
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
          VerticalDivider(width: 0, thickness: 1, color: Colors.grey.shade200),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusBadge(item.trangThai),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isOnline
                                  ? Colors.blue.shade50
                                  : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                isOnline
                                    ? Colors.blue.shade700
                                    : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.lopHoc?.tenMon ?? 'Môn học',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Học viên: ${item.lopHoc?.tenNguoiHoc ?? "---"}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (!isOnline) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            diaChi,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              () => showDialog(
                                context: context,
                                builder:
                                    (_) => ChiTietLichHocDialog(
                                      lichHoc: item,
                                      isGiaSu: true,
                                    ),
                              ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 36),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                      if (item.trangThai != 'DaHoc' && item.trangThai != 'Huy')
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => showDialog(
                                  context: context,
                                  builder:
                                      (_) => SuaLichHocDialog(
                                        lichHoc: item,
                                        isOnlineClass: isOnline,
                                        onUpdate: (st, link) {
                                          context.read<LichHocBloc>().add(
                                            UpdateLichHoc(
                                              lichHocId: item.lichHocID,
                                              trangThai: st,
                                              duongDan: link,
                                            ),
                                          );
                                        },
                                      ),
                                ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              side: BorderSide(color: Colors.orange.shade200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cập nhật',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                        ),
                      // SỬA: Chỉ hiện nút tham gia nếu có link VÀ trạng thái không phải là Đã học hoặc Hủy
                      if (hasLink &&
                          item.trangThai != 'DaHoc' &&
                          item.trangThai != 'Huy') ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _launchLink(item.duongDan!),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Tham gia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildStatusBadge(String status) {
    String text;
    Color color;
    switch (status) {
      case 'DaHoc':
        text = 'Đã dạy';
        color = Colors.green;
        break;
      case 'DangDay':
        text = 'Đang dạy';
        color = Colors.orange;
        break;
      case 'Huy':
        text = 'Đã hủy';
        color = Colors.red;
        break;
      default:
        text = 'Sắp tới';
        color = AppColors.primary;
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

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('Trống lịch', style: TextStyle(color: Colors.grey.shade500)),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: TextButton(
      onPressed: _loadLichHocCalendar,
      child: const Text("Thử lại"),
    ),
  );

  String _formatTime(String time) {
    try {
      return time.split(':').sublist(0, 2).join(':');
    } catch (_) {
      return time;
    }
  }

  Future<void> _launchLink(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi mở link')));
    }
  }
}
