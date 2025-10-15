import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_bottom_nav_bar.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_button.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';

// ============= MODEL =============
class LopHoc {
  final String maLop;
  final String tenLop;
  final String tenHocVien;
  final String diaChi;
  final int hocPhi;
  final int phiNhanLop;

  LopHoc({
    required this.maLop,
    required this.tenLop,
    required this.tenHocVien,
    required this.diaChi,
    required this.hocPhi,
    required this.phiNhanLop,
  });
}

// ============= CARD HIỂN THỊ MỖI LỚP =============
class LopHocCard extends StatelessWidget {
  final LopHoc lopHoc;
  final VoidCallback onDeNghiDay;

  const LopHocCard({Key? key, required this.lopHoc, required this.onDeNghiDay})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mã lớp: ${lopHoc.maLop} - ${lopHoc.tenLop}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                Text("${lopHoc.hocPhi} vnd/Buổi"),
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
              child: CustomButton(text: "Đề nghị dạy", onPressed: onDeNghiDay),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= TRANG DANH SÁCH LỚP =============
class TutorListPage extends StatelessWidget {
  const TutorListPage({super.key});

  final curentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundImage: AssetImage('')),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Xin chào, Trần Minh Luân',
                style: TextStyle(fontSize: 14),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchBarCustom(onFilter: () {}),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'DANH SÁCH LỚP CHƯA GIAO',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: .3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  // 👉 DANH SÁCH LỚP HIỂN THỊ Ở ĐÂY
                  ...dsLopHoc.map(
                    (lop) => LopHocCard(
                      lopHoc: lop,
                      onDeNghiDay: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã đề nghị dạy lớp ${lop.maLop}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        role: 'tutor',
        currentIndex: 0,
        onTap: (i) {
          if (i == curentIndex) return;
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/tutor',
              (route) => false,
            );
          } else if (i == 1) {
            Navigator.pushNamed(context, '/schedule');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/my-classes');
          } else {
            Navigator.pushNamed(context, '/account');
          }
        },
      ),
    );
  }
}

// ============= DỮ LIỆU GIẢ LẬP =============
final dsLopHoc = [
  LopHoc(
    maLop: "0001",
    tenLop: "Anh văn 12 + Toán",
    tenHocVien: "Trần Minh Luân",
    diaChi: "Ấp 5, Tân Tây, Gò Công Đông, Tiền Giang",
    hocPhi: 180000,
    phiNhanLop: 650000,
  ),
  LopHoc(
    maLop: "0002",
    tenLop: "Toán 9 + Lý 9",
    tenHocVien: "Nguyễn Hồng Anh",
    diaChi: "Ấp 3, Phước Lâm, Cần Giuộc, Long An",
    hocPhi: 150000,
    phiNhanLop: 500000,
  ),
  LopHoc(
    maLop: "0003",
    tenLop: "Hóa 11 + Sinh 11",
    tenHocVien: "Lê Hữu Đạt",
    diaChi: "Phú Mỹ, Tân Thành, Bà Rịa - Vũng Tàu",
    hocPhi: 200000,
    phiNhanLop: 700000,
  ),
  LopHoc(
    maLop: "0004",
    tenLop: "Toán 12 + Lý 12",
    tenHocVien: "Phạm Thùy Dương",
    diaChi: "Phước Vĩnh An, Củ Chi, TP.HCM",
    hocPhi: 220000,
    phiNhanLop: 800000,
  ),
  LopHoc(
    maLop: "0005",
    tenLop: "Toán 6 + Tiếng Anh 6",
    tenHocVien: "Ngô Văn Minh",
    diaChi: "Bình Chánh, TP.HCM",
    hocPhi: 130000,
    phiNhanLop: 400000,
  ),
];
