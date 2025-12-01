import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_detail_screen.dart';

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
    return GestureDetector(
      onTap:
          onTap ??
          () {
            context.read<TutorBloc>().add(LoadTutorByIdEvent(tutor.giaSuID));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider.value(
                      value: context.read<TutorBloc>(),
                      child: TutorDetailPage(tutorId: tutor.giaSuID),
                    ),
              ),
            );
          },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image Area (Expanded to fill space in Grid)
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildTutorImage(),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            tutor.diemSo.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Info Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.hoTen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutor.bangCap ?? 'Chưa cập nhật',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 10),

                  if (onOfferTap != null)
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: onOfferTap,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.05,
                          ),
                        ),
                        child: Text(
                          'Mời dạy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
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
    );
  }

  Widget _buildTutorImage() {
    if (tutor.anhDaiDien == null || tutor.anhDaiDien!.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Icon(Icons.person, size: 48, color: Colors.grey.shade300),
      );
    }
    return CachedNetworkImage(
      imageUrl: tutor.anhDaiDien!,
      fit: BoxFit.cover,
      memCacheWidth: 200,
      memCacheHeight: 200,
      cacheKey: 'tutor_${tutor.giaSuID}',
      placeholder:
          (context, url) => Container(
            color: Colors.grey.shade50,
            child: Icon(Icons.person, size: 48, color: Colors.grey.shade300),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: Colors.grey.shade100,
            child: Icon(Icons.person, size: 48, color: Colors.grey.shade300),
          ),
    );
  }
}
