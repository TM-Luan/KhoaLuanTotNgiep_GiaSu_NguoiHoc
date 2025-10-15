
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/LopHoc.dart';

class LopHocCard extends StatelessWidget {
  final LopHoc lopHoc;
  final VoidCallback onDeNghiDay;

  const LopHocCard({
    Key? key,
    required this.lopHoc,
    required this.onDeNghiDay,
  }) : super(key: key);

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
              "Mã lớp: ${lopHoc.maLop} - ${lopHoc.tenLop}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(lopHoc.tenHocVien),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(lopHoc.diaChi)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${lopHoc.hocPhi.toString()} vnd/Buổi"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.receipt_long, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text("Phí nhận lớp: ${lopHoc.phiNhanLop} vnd"),
              ],
            ),
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
                child: const Text("Đề nghị dạy"),
              ),
            )
          ],
        ),
      ),
    );
  }
}