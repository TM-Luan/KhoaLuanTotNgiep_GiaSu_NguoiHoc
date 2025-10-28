// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';

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
          border: Border.all(color: AppColors.grey.withOpacity(0.5)),
          boxShadow: [
             BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
             )
          ],
        ),
        child: ClipRRect(
           borderRadius: BorderRadius.circular(12),
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  tutor.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.lightGrey,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)), // Giảm độ dày indicator
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.lightGrey,
                    child: Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: AppColors.grey.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),

              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisSize: MainAxisSize.min,
                         children: [
                            Text(
                              tutor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tutor.subject ?? 'Chưa cập nhật',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13, 
                                color: Colors.grey[700],
                                height: 1.2,
                              ),
                            ),
                         ],
                      ),


                      // Rating và nút đề nghị dạy
                      // ✅ Bỏ SizedBox cố định chiều cao
                      Row(
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
                          const Spacer(), // Đẩy nút sang phải
                          // Nút "Đề nghị dạy" - Giữ nguyên hoặc tùy chỉnh style
                          InkWell(
                            onTap: onOfferTap,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, // Giảm padding ngang
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Đề nghị dạy',
                                style: TextStyle(
                                  fontSize: 11, // Giảm font size
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
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
            ],
          ),
        ),
      ),
    );
  }
}