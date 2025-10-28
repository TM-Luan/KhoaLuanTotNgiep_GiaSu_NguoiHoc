// FILE 2: CẬP NHẬT UI CARD ĐỂ DÙNG MODEL MỚI
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';

class LopHocCard extends StatelessWidget {
  final LopHoc lopHoc;
  final VoidCallback onDeNghiDay;

  const LopHocCard({super.key, required this.lopHoc, required this.onDeNghiDay});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Đã sửa: dùng .toString() và .tieuDeLop
              "Mã lớp: ${lopHoc.maLop.toString()} - ${lopHoc.tieuDeLop}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                // Đã sửa: dùng .tenNguoiHoc
                Text(lopHoc.tenNguoiHoc),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                // Đã sửa: Thêm kiểm tra null ??
                Expanded(child: Text(lopHoc.diaChi ?? 'Chưa cập nhật địa chỉ')),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                // Đã sửa: .hocPhi (vì nó đã là String)
                Text(lopHoc.hocPhi),
              ],
            ),
            
            // Đã xóa: Dòng "Phí nhận lớp"
            // Vì LopHocYeuCauResource.php của bạn không trả về trường này

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onDeNghiDay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Đề nghị dạy",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
