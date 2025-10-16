import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/account_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/student_schedule_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/student_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/tutor_home_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/tutor_schedule_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

final String role = "gia ";

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;

  final List<Widget> pages = [
    if (role == "gia sư") const TutorListPage() else const LearnerHomePage(),

    if (role == "gia sư")
      const TutorSchedulePage()
    else
      const LearnerSchedulePage(),
    const LopCuaToi(),
    const Account(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: CircleAvatar(),
        title: Text(
          "Xin chào, Trần Minh Luân",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
            color: AppColors.white,
          ),
        ],
      ),
      body: pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.lightwhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(icon: Icons.home_filled, label: "Trang chủ", index: 0),
          buildNavItem(icon: Icons.calendar_today, label: "Lịch", index: 1),
          buildNavItem(icon: Icons.table_chart, label: "Lớp", index: 2),
          buildNavItem(icon: Icons.person, label: "Tài khoản", index: 3),
        ],
      ),
    );
  }

  Widget buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          pageIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: pageIndex == index ? AppColors.lightBlue : AppColors.black,
            size: 30,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: pageIndex == index ? AppColors.lightBlue : AppColors.black,
              fontSize: 12,
              fontWeight:
                  pageIndex == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class DanhSachLopChuaGiao extends StatelessWidget {
  const DanhSachLopChuaGiao({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SearchBarCustom(onFilter: () {}),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "DANH SÁCH LỚP CHƯA GIAO",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildClassCard(
            "0001",
            "Anh văn 12 + Toán",
            "Trần Minh Luân",
            "Áp 5, tân tay, gò công đông, tiễn giang",
            180000,
            650000,
          ),
          _buildClassCard(
            "0002",
            "Hóa học 12 + Sinh học",
            "Lê Thị Mai",
            "Khu phố 1, thị trấn Bình Chánh",
            150000,
            600000,
          ),
          _buildClassCard(
            "0003",
            "Vật lý 12 + Toán",
            "Nguyễn Văn Hòa",
            "Đường Tô Ký, quận 12, TP.HCM",
            200000,
            700000,
          ),
        ],
      ),
    );
  }

  Container _buildClassCard(
    String classCode,
    String className,
    String teacherName,
    String location,
    int pricePerSession,
    int totalFee,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Mã lớp: $classCode - $className",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Giáo viên: $teacherName",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 5),
          Text(
            "Địa điểm: $location",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "$pricePerSession vnđ/ Buổi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Phí nhận lớp: $totalFee vnđ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text("Đề nghị dạy"),
                style: ElevatedButton.styleFrom(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LopCuaToi extends StatelessWidget {
  const LopCuaToi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Thông tin lớp của tôi sẽ hiển thị ở đây.",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
