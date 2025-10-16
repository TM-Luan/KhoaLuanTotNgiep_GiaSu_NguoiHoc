// widgets/schedule_card.dart
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/schedule_data.dart';

class ScheduleCard extends StatelessWidget {
  final LichHoc schedule;
  final String role;
  final VoidCallback onDetails;
  final VoidCallback? onPrimaryAction;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.role,
    required this.onDetails,
    this.onPrimaryAction,
  });

  String _getPrimaryActionText() {
    if (role == 'tutor') {
      return 'Sửa Lịch';
    } else {
      return 'Tham gia Online';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.tenLop,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 4),
            Text(
              'Môn học: ${schedule.monHoc}',
              style: const TextStyle(color: AppColors.black, fontSize: 14),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text('${schedule.thoiGianBD} - ${schedule.thoiGianKT}'),
              ],
            ),
            const SizedBox(height: 4),
            
            Row(
              children: [
                Icon(
                  role == 'tutor' ? Icons.location_on : Icons.person,
                  size: 16,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 4),
                Text(role == 'tutor' ? schedule.diaDiem : 'GV: ${schedule.tenGiaSu}'),
              ],
            ),
            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onDetails,
                  child: const Text(
                    'Xem chi tiết',
                    style: TextStyle(color: AppColors.lightBlue),
                  ),
                ),

                // Nút Hành động chính (Sửa/Tham gia)
                if (onPrimaryAction != null)
                  ElevatedButton(
                    onPressed: onPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: role == 'tutor' ? AppColors.lightBlue : Colors.green, // Màu xanh lá cho tham gia
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _getPrimaryActionText(),
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}