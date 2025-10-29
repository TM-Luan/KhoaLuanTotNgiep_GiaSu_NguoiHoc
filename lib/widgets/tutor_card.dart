import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_detail_page.dart';

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
      onTap: onTap ?? () {
        // Navigate to tutor detail using BLoC
        context.read<TutorBloc>().add(LoadTutorByIdEvent(tutor.giaSuID));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<TutorBloc>(),
              child: TutorDetailPage(tutorId: tutor.giaSuID),
            ),
          ),
        );
      },
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
                child: _buildTutorImage(),
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
                            tutor.hoTen,
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
                            tutor.bangCap ?? 'Chưa cập nhật',
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
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rate_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tutor.diemSo.toStringAsFixed(1),
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
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Đề nghị dạy',
                                style: TextStyle(
                                  fontSize: 11,
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

  Widget _buildTutorImage() {
    if (tutor.anhDaiDien == null || tutor.anhDaiDien!.isEmpty) {
      return Container(
        color: AppColors.lightGrey,
        child: Center(
          child: Icon(
            Icons.person_outline,
            size: 40,
            color: AppColors.grey.withOpacity(0.7),
          ),
        ),
      );
    }

    return Image.network(
      tutor.anhDaiDien!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.lightGrey,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
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
    );
  }
}