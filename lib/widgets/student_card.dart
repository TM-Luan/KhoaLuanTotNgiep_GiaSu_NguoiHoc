// FILE 1: CẬP NHẬT student_card.dart
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';

class LopHocCard extends StatelessWidget {
  final LopHoc lopHoc;
  final VoidCallback onDeNghiDay;
  final VoidCallback onCardTap; // <-- THÊM CALLBACK MỚI

  const LopHocCard({
    super.key,
    required this.lopHoc,
    required this.onDeNghiDay,
    required this.onCardTap, // <-- THÊM VÀO CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    // BỌC CARD BẰNG INKWELL ĐỂ CÓ SỰ KIỆN ONTAP
    return InkWell(
      onTap: onCardTap, // <-- GỌI CALLBACK KHI NHẤN VÀO CARD
      splashColor: Colors.blue.withAlpha(30), // Hiệu ứng khi nhấn
      borderRadius: BorderRadius.circular(12), // Bo góc cho hiệu ứng
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mã lớp: ${lopHoc.maLop.toString()} - ${lopHoc.tieuDeLop}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(lopHoc.tenNguoiHoc),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(lopHoc.diaChi ?? 'Chưa cập nhật địa chỉ')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(lopHoc.hocPhi),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onDeNghiDay, // Nút này vẫn hoạt động
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
      ),
    );
  }
}