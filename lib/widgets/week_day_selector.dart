// widgets/week_day_selector.dart
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class WeekDaySelector extends StatelessWidget {
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) hasSchedule; // Hàm kiểm tra lịch có tồn tại không

  const WeekDaySelector({
    super.key,
    required this.weekDays,
    required this.selectedDate,
    required this.onDateSelected,
    required this.hasSchedule,
  });

  // Helper để lấy tên ngày (T2, T3, CN,...)
  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children:
            weekDays.map((date) {
              final bool isSelected =
                  date.day == selectedDate.day &&
                  date.month == selectedDate.month;
              final bool has = hasSchedule(date);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => onDateSelected(date),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primaryBlue
                              : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          has && !isSelected
                              ? Border.all(
                                color: AppColors.primaryBlue,
                                width: 2,
                              )
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayName(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                isSelected ? AppColors.white : AppColors.black,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected ? AppColors.white : AppColors.grey,
                          ),
                        ),
                        if (has && !isSelected)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
