import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_info_row.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class LopHocCard extends StatelessWidget {
  final LopHoc lopHoc;
  final VoidCallback onDeNghiDay;
  final VoidCallback onCardTap;

  const LopHocCard({
    super.key,
    required this.lopHoc,
    required this.onDeNghiDay,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tính phí nhận lớp (nếu có logic)
    final phiNhanLop = tinhPhiNhanLop(
      hocPhiMotBuoi: toNumber(lopHoc.hocPhi),
      soBuoiMotTuan: lopHoc.soBuoiTuan,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCardTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.class_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lopHoc.tieuDeLop,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mã: ${lopHoc.maLop}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),

                // --- Body Info ---
                InfoRow(
                  icon: Icons.person_outline,
                  label: "Học viên",
                  value: lopHoc.tenNguoiHoc,
                ),
                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.monetization_on_outlined,
                  label: "Học phí",
                  value: '${formatNumber(toNumber(lopHoc.hocPhi))} đ/Buổi',
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (lopHoc.diaChi?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    label: "Địa chỉ",
                    value: lopHoc.diaChi!,
                  ),
                ],

                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.verified_outlined,
                  label: "Phí nhận lớp",
                  value:
                      phiNhanLop != null
                          ? '${formatNumber(phiNhanLop)} đ'
                          : 'Miễn phí',
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        phiNhanLop != null
                            ? Colors.orange.shade800
                            : Colors.green,
                  ),
                ),

                const SizedBox(height: 16),

                // --- Footer Action ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onDeNghiDay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Màu chủ đạo
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Đề nghị dạy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
