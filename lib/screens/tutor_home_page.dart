import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/student_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_class_detail_page.dart';

class TutorHomePage extends StatefulWidget {
  final UserProfile? userProfile; // THÊM PROPERTY

  const TutorHomePage({super.key, this.userProfile});

  @override
  State<TutorHomePage> createState() => _TutorHomePageState();
}

class _TutorHomePageState extends State<TutorHomePage> {
  final LopHocRepository _lopHocRepo = LopHocRepository();
  YeuCauNhanLopRepository? _yeuCauRepo;
  bool _isLoading = true;
  List<LopHoc> _lopHocList = [];
  String? _errorMessage;
  UserProfile? currentProfile;

  @override
  void initState() {
    super.initState();
    currentProfile = widget.userProfile;
    _fetchLopHocChuaGiao();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _yeuCauRepo ??= context.read<YeuCauNhanLopRepository>();
  }

  // GETTERS ĐỂ HIỂN THỊ THÔNG TIN NGƯỜI DÙNG
  String get displayName {
    return currentProfile?.hoTen ?? 'Gia sư';
  }

  String get avatarText {
    final userName = currentProfile?.hoTen ?? '';
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
  }

  Future<void> _fetchLopHocChuaGiao() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ApiResponse<List<LopHoc>> response = await _lopHocRepo
        .getLopHocByTrangThai('TimGiaSu');

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

  Future<void> _handleDeNghiDay(LopHoc lop) async {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để gửi đề nghị.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final giaSuId = authState.user.giaSuID;
    final taiKhoanId = authState.user.taiKhoanID;

    if (giaSuId == null || taiKhoanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ gia sư mới có thể gửi đề nghị.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_yeuCauRepo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi hệ thống. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Đang gửi đề nghị...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final response = await _yeuCauRepo!.giaSuGuiYeuCau(
        lopId: lop.maLop,
        giaSuId: giaSuId,
        nguoiGuiTaiKhoanId: taiKhoanId,
      );

      // Hide loading snackbar first
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Wait a bit to ensure loading snackbar is completely hidden
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã gửi đề nghị dạy lớp "${lop.tieuDeLop}" thành công!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Hiển thị thông báo lỗi từ server với màu cam để phân biệt
        final errorMessage = response.message.isNotEmpty 
            ? response.message 
            : 'Không thể gửi đề nghị. Vui lòng thử lại.';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi kết nối: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _navigateToDetail(LopHoc lop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorClassDetailPage(lopHocId: lop.maLop),
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
            // HIỂN THỊ TÊN NGƯỜI DÙNG - GIỐNG NHƯ LEARNER HOME SCREEN
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              color: AppColors.primaryBlue,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Xin chào, $displayName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SearchBarCustom(onFilter: () {}),
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
            Expanded(child: _buildLopHocList()),
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
              ),
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
          onCardTap: () => _navigateToDetail(lop),
        );
      },
    );
  }
}
