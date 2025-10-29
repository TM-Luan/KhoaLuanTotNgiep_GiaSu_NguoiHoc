// screens/tutor_home_page.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/student_card.dart'; // Đổi tên thành LopHocCard nếu cần
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';

// ===> ĐỔI TÊN LỚP <===
class TutorHomePage extends StatefulWidget { // Đổi từ TutorListPage
  const TutorHomePage({super.key}); // Đổi constructor

  @override
  // ===> ĐỔI TÊN STATE <===
  State<TutorHomePage> createState() => _TutorHomePageState(); // Đổi State
}

// ===> ĐỔI TÊN STATE <===
class _TutorHomePageState extends State<TutorHomePage> { // Đổi từ _TutorListPageState
  final LopHocRepository _lopHocRepo = LopHocRepository();
  bool _isLoading = true;
  List<LopHoc> _lopHocList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLopHocChuaGiao();
  }

  Future<void> _fetchLopHocChuaGiao() async {
     setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Log bắt đầu gọi API
    print('>>> [TutorHomePage] Calling API: getLopHocTimGiaSu...');

    final ApiResponse<List<LopHoc>> response =
        await _lopHocRepo.getLopHocTimGiaSu();

    // Log kết quả API (giữ lại để kiểm tra)
    print('--- KẾT QUẢ API LỚP HỌC ---');
    print('Thành công (Success): ${response.success}');
    print('StatusCode: ${response.statusCode}');
    print('Lỗi (Message): ${response.message}');
    print('Dữ liệu (Data): ${response.data}'); // Sẽ in [Instance of 'LopHoc', ...] nếu thành công
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
      print('>>> [TutorHomePage] Đề nghị dạy lớp: ${lop.maLop}'); // Thêm log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đề nghị dạy lớp ${lop.maLop}'),
          duration: const Duration(seconds: 1), // Giảm thời gian hiển thị
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            Padding( // Thêm Padding cho SearchBar
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SearchBarCustom(onFilter: () {
                print('>>> [TutorHomePage] Filter button tapped.'); // Thêm log
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

    // Đảm bảo dùng LopHocCard (tên đúng từ student_card.dart)
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 100),
      itemCount: _lopHocList.length,
      itemBuilder: (context, index) {
        final lop = _lopHocList[index];
        return LopHocCard( // Đảm bảo đây là tên widget đúng
          lopHoc: lop,
          onDeNghiDay: () => _handleDeNghiDay(lop),
        );
      },
    );
  }
}