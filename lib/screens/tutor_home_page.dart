import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/student_card.dart';

class TutorListPage extends StatelessWidget {
  const TutorListPage({super.key});

  final curentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
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
    );
  }
}

final List<LopHoc> dsLopHoc = [
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
