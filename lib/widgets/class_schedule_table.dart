import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_time_slot.dart';

class ClassScheduleTable extends StatelessWidget {
  final Map<int, List<String>> availableSlots;

  const ClassScheduleTable({super.key, required this.availableSlots});

  @override
  Widget build(BuildContext context) {
    // ✅ Đủ 7 ngày trong tuần
    const List<String> days = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật'
    ];

    const List<String> slots = ['Buổi sáng', 'Buổi chiều', 'Buổi tối'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < days.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    days[i],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: slots.map((slot) {
                      // ✅ index + 2 tương ứng: Thứ 2 = 2, Thứ 3 = 3, ..., CN = 8
                      bool isAvailable = availableSlots[i + 2]?.contains(slot) ?? false;
                      return ClassTimeSlot(text: slot, isAvailable: isAvailable);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
