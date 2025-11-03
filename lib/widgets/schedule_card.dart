// widgets/schedule_card.dart
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 0),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.successSurface,
              AppColors.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.iconContainerPadding),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.iconContainerRadius),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: AppColors.success,
                      size: AppSpacing.smallIconSize,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      schedule.tenLop,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTypography.body1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Thông tin thu gọn
              Row(
                children: [
                  Expanded(
                    child: _buildCompactInfo(Icons.book, schedule.monHoc),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactInfo(Icons.access_time, '${schedule.thoiGianBD} - ${schedule.thoiGianKT}'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              _buildCompactInfo(
                role == 'tutor' ? Icons.location_on : Icons.person,
                role == 'tutor' ? schedule.diaDiem : 'GV: ${schedule.tenGiaSu}',
              ),
              
              const SizedBox(height: AppSpacing.sm),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút chi tiết
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: InkWell(
                      onTap: onDetails,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.buttonPaddingHorizontal,
                          vertical: AppSpacing.buttonPaddingVertical,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: AppSpacing.buttonIconSize,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Chi tiết',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: AppTypography.buttonText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Nút hành động chính
                  if (onPrimaryAction != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
                        gradient: LinearGradient(
                          colors: role == 'tutor' 
                              ? [Colors.blue.shade400, Colors.blue.shade600]
                              : [Colors.green.shade400, Colors.green.shade600],
                        ),
                      ),
                      child: InkWell(
                        onTap: onPrimaryAction,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                role == 'tutor' ? Icons.edit : Icons.videocam,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getPrimaryActionText(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
    );
  }

  // Widget thông tin thu gọn
  Widget _buildCompactInfo(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSpacing.buttonIconSize,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.buttonText,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}