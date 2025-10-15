import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/tutor.dart';

class TutorCard extends StatelessWidget {
  final Tutor tutor;
  final VoidCallback? onTap;

  const TutorCard({super.key, required this.tutor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  tutor.image.isNotEmpty
                      ? Image.network(
                        tutor.image,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: 120,
                        color: AppColors.grey,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutor.subject,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(tutor.rating.toStringAsFixed(1)),
                    ],
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
