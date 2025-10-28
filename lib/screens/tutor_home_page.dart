
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart'; // Import Repository
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/student_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart'; // Import ApiResponse

// Đổi thành StatefulWidget
class TutorListPage extends StatefulWidget {
  const TutorListPage({super.key});

  @override
  State<TutorListPage> createState() => _TutorListPageState();
}

class _TutorListPageState extends State<TutorListPage> {
  // Khai báo Repository
  final LopHocRepository _lopHocRepo = LopHocRepository();

  // Biến trạng thái
  bool _isLoading = true;
  List<LopHoc> _lopHocList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Gọi API khi màn hình khởi tạo
    _fetchLopHocChuaGiao();
  }

  // Hàm gọi API
  Future<void> _fetchLopHocChuaGiao() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset lỗi cũ
    });

    final ApiResponse<List<LopHoc>> response =
        await _lopHocRepo.getLopHocTimGiaSu();

    if (mounted) { // Kiểm tra xem Widget còn tồn tại không
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

  // Hàm xử lý khi nhấn "Đề nghị dạy" (ví dụ)
  void _handleDeNghiDay(LopHoc lop) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đề nghị dạy lớp ${lop.maLop}'),
        ),
      );
      // Ở đây bạn có thể gọi API khác để gửi yêu cầu nhận lớp
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            SearchBarCustom(onFilter: () {}), // Giữ lại thanh tìm kiếm
            const SizedBox(height: 8),
            const Padding( // Giữ lại tiêu đề
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
            // === Phần hiển thị danh sách ===
            Expanded(
              child: _buildLopHocList(), // Gọi hàm xây dựng danh sách
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng nội dung danh sách (Loading, Lỗi, hoặc Danh sách thật)
  Widget _buildLopHocList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); // Hiển thị loading
    }

    if (_errorMessage != null) {
      return Center( // Hiển thị lỗi
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_errorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchLopHocChuaGiao, // Nút thử lại
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
      );
    }

    if (_lopHocList.isEmpty) {
        return const Center(child: Text('Không có lớp nào cần tìm gia sư.')); // Thông báo rỗng
    }

    // Hiển thị danh sách thật dùng ListView.builder
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 100), // Giảm padding ngang
      itemCount: _lopHocList.length,
      itemBuilder: (context, index) {
        final lop = _lopHocList[index];
        return LopHocCard(
          lopHoc: lop,
          onDeNghiDay: () => _handleDeNghiDay(lop), // Truyền hàm xử lý
        );
      },
    );
  }
}

// XÓA DỮ LIỆU GIẢ LẬP Ở ĐÂY
// final List<LopHoc> dsLopHoc = [ ... ];
