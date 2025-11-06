import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/untils/format_vnd.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_info_row.dart';

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
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: InkWell(
          onTap: onCardTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Mã lớp + Tiêu đề
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.blue.shade700,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Mã lớp: ${lopHoc.maLop} - ${lopHoc.tieuDeLop}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Thông tin học viên và học phí
                InfoRow(
                  icon: Icons.person,
                  label: "Học viên",
                  value: lopHoc.tenNguoiHoc,
                ),
                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.attach_money,
                  label: "Học phí",
                  value: formatCurrency(lopHoc.hocPhi),
                ),

                // Địa chỉ (nếu có)
                if (lopHoc.diaChi?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  InfoRow(
                    icon: Icons.location_on,
                    label: "Địa chỉ",
                    value: lopHoc.diaChi!,
                  ),
                ],

                const SizedBox(height: 12),
                InfoRow(
                  icon: Icons.money_off,
                  label: "Phí nhận lớp",
                  value: formatPhi(lopHoc.hocPhi),
                  valueStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),
                // Nút "Đề nghị dạy"
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                    ),
                    child: InkWell(
                      onTap: onDeNghiDay,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.send, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "Đề nghị dạy",
                              style: TextStyle(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
