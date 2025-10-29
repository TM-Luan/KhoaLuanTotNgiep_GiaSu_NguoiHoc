// screens/tutor_home_page.dart
// (ĐÃ ĐƯỢC CHỈNH SỬA)

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/student_card.dart';import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';

// === THÊM IMPORT CHO TRANG CHI TIẾT ===
// (Đảm bảo đường dẫn này đúng với cấu trúc dự án của bạn)
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_class_detail_page.dart'; 


class TutorHomePage extends StatefulWidget { 
  const TutorHomePage({super.key}); 

  @override
  State<TutorHomePage> createState() => _TutorHomePageState(); 
}

class _TutorHomePageState extends State<TutorHomePage> { 
  final LopHocRepository _lopHocRepo = LopHocRepository();
  bool _isLoading = true;
  List<LopHoc> _lopHocList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLopHocChuaGiao();
  }

  // === SỬA LẠI HÀM NÀY ĐỂ GỌI ĐÚNG TÊN HÀM MỚI TRONG REPOSITORY ===
  Future<void> _fetchLopHocChuaGiao() async {
     setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    print('>>> [TutorHomePage] Calling API: getLopHocByTrangThai(\'TimGiaSu\')...');

    // Sửa tên hàm: getLopHocTimGiaSu() -> getLopHocByTrangThai()
    final ApiResponse<List<LopHoc>> response =
        await _lopHocRepo.getLopHocByTrangThai('TimGiaSu');

    // (Các log của bạn vẫn giữ nguyên)
    print('--- KẾT QUẢ API LỚP HỌC ---');
    print('StatusCode: ${response.statusCode}');
    print('Lỗi (Message): ${response.message}');
    print('-----------------------------');

    if (mounted) {
      if (response.isSuccess && response.data != null) {
        setState(() {
          _lopHocList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    }
  }

  void _handleDeNghiDay(LopHoc lop) {
      print('>>> [TutorHomePage] Đề nghị dạy lớp: ${lop.maLop}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đề nghị dạy lớp ${lop.maLop}'),
          duration: const Duration(seconds: 1), 
        ),
      );
  }

  // === THÊM LẠI HÀM ĐIỀU HƯỚNG (NAVIGATE) ===
  void _navigateToDetail(LopHoc lop) {
    print('>>> [TutorHomePage] Navigating to detail for class ID: ${lop.maLop}');
    Navigator.push(
      context,
      MaterialPageRoute(
        // Chúng ta dùng MaterialPageRoute, không dùng router.dart
        builder: (context) => TutorClassDetailPage(lopHocId: lop.maLop),
      ),
    );
  }
  // === KẾT THÚC THÊM ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            Padding( 
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SearchBarCustom(onFilter: () {
                print('>>> [TutorHomePage] Filter button tapped.');
              }),
            ),
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
              child: _buildLopHocList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLopHocList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_errorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchLopHocChuaGiao,
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
      );
    }

    if (_lopHocList.isEmpty) {
        return const Center(child: Text('Không có lớp nào cần tìm gia sư.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 100),
      itemCount: _lopHocList.length,
      itemBuilder: (context, index) {
        final lop = _lopHocList[index];
        return LopHocCard( 
          lopHoc: lop,
          onDeNghiDay: () => _handleDeNghiDay(lop),
          // === THÊM LẠI CALLBACK BỊ THIẾU ===
          onCardTap: () => _navigateToDetail(lop), 
        );
      },
    );
  }
}