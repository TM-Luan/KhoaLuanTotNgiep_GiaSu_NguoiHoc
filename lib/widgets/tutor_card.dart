import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/tutor.dart';

class TutorCard extends StatelessWidget {
  final Tutor tutor;
  final VoidCallback? onTap;
  final VoidCallback? onOfferTap;

  const TutorCard({
    super.key,
    required this.tutor,
    this.onTap,
    this.onOfferTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey),
          boxShadow: [BoxShadow(color: AppColors.black, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                child: Image.network(
                  tutor.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.grey,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: AppColors.grey,
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                ),
              ),
            ),

            // Thông tin gia sư
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên gia sư
                  Text(
                    tutor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Môn học
                  Text(
                    tutor.subject,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating và nút đề nghị dạy
                  SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        // Rating
                        const Icon(
                          Icons.star_rate_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tutor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),

                        const Spacer(),
                        InkWell(
                          onTap: onOfferTap,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Đề nghị dạy',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
