import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/add_class_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_class_proposals_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';

class StudentMyClassesPage extends StatefulWidget {
  const StudentMyClassesPage({super.key});

  @override
  State<StudentMyClassesPage> createState() => _StudentMyClassesPageState();
}

class _StudentMyClassesPageState extends State<StudentMyClassesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LopHocRepository _lopHocRepo = LopHocRepository();
  late StreamSubscription<ProposalUpdateEvent> _proposalUpdateSubscription;

  bool _isLoading = true;
  String? _errorMessage;

  // Danh sách cho từng tab
  List<LopHoc> _lopHocTimGiaSu = [];
  List<LopHoc> _lopHocDangDay = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với 2 tab
    _tabController = TabController(length: 2, vsync: this);
    
    // Lắng nghe notification về proposal updates
    _proposalUpdateSubscription = GlobalNotificationService()
        .proposalUpdateStream
        .listen((event) {
      // Refresh data khi có proposal được chấp nhận/từ chối  
      print('🔔 Student screen nhận notification proposal update: ${event.type}, classId: ${event.classId}');
      _fetchClasses();
    });
    
    _fetchClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _proposalUpdateSubscription.cancel();
    super.dispose();
  }

  // Hàm gọi API cho tất cả các tab
  Future<void> _fetchClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lopHocTimGiaSu = []; // Xóa dữ liệu cũ
      _lopHocDangDay = []; // Xóa dữ liệu cũ
    });

    try {
      // 1. GỌI API MỚI (CHỈ 1 LẦN)
      final response = await _lopHocRepo.getLopHocCuaNguoiHoc();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final List<LopHoc> tatCaLopCuaToi = response.data!;

        // 2. TỰ LỌC RA 2 DANH SÁCH CHO 2 TAB
        setState(() {
          _lopHocTimGiaSu = tatCaLopCuaToi
              .where((lop) => lop.trangThai == 'TimGiaSu' || lop.trangThai == 'ChoDuyet')
              .toList();

          _lopHocDangDay = tatCaLopCuaToi
              .where((lop) => lop.trangThai == 'DangHoc')
              .toList();
        });
      } else {
        // Nếu API thất bại
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Icon(
                Icons.school,
                color: AppColors.primary,
                size: AppSpacing.iconSize,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Lớp của tôi',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                fontSize: AppTypography.appBarTitle,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddClassPage()),
                  );
                },
                icon: Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: AppSpacing.smallIconSize,
                ),
                tooltip: 'Thêm Lớp',
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: AppColors.grey100,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppTypography.body2,
              ),
              tabs: const [
                Tab(text: 'Đang Tìm Gia Sư'),
                Tab(text: 'Đang Học'),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Hàm xây dựng Body
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $_errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchClasses,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Hiển thị TabBarView
    return TabBarView(
      controller: _tabController,
      children: [
        _buildClassListView(
          _lopHocTimGiaSu,
          'Không có lớp nào đang tìm gia sư.',
        ),
        _buildClassListView(_lopHocDangDay, 'Không có lớp nào đang dạy.'),
      ],
    );
  }

  // Hàm xây dựng danh sách cho mỗi tab
  Widget _buildClassListView(List<LopHoc> lopHocList, String emptyMessage) {
    if (lopHocList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.class_outlined, size: 50, color: Colors.black54),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lopHocList.length,
      itemBuilder: (context, index) {
        final lop = lopHocList[index];
        return _buildClassCard(context, lop);
      },
    );
  }

  // Hàm tiện ích để xây dựng hàng thông tin với Icon
  Widget _buildInfoRow(IconData icon, String text, [Color? iconColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // Widget xây dựng thẻ lớp học (Dùng model LopHoc thật)
  Widget _buildClassCard(BuildContext context, LopHoc lopHoc) {
    // Lấy trạng thái từ API
    final String status = lopHoc.trangThai ?? 'N/A';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info_outline;

    // Xác định màu sắc và icon dựa trên trạng thái
    if (status == 'DangHoc') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'TimGiaSu') {
      statusColor = Colors.orange;
      statusIcon = Icons.search;
    } else if (status == 'ChoDuyet') {
      statusColor = Colors.blue;
      statusIcon = Icons.pending_outlined;
    }

    return GestureDetector(
      onTap: () {
        // Điều hướng đến trang chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => StudentClassDetailScreen(classId: lopHoc.maLop),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 175, 175, 175),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Mã lớp: ${lopHoc.maLop} - ${lopHoc.tieuDeLop}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tên gia sư (lấy từ API)
            _buildInfoRow(
              Icons.person,
              lopHoc.tenGiaSu ?? 'Chưa có gia sư', // Dùng dữ liệu mới
              Colors.grey,
            ),

            // Địa chỉ
            _buildInfoRow(
              Icons.location_on,
              lopHoc.diaChi ?? 'Chưa cập nhật',
              Colors.grey,
            ),

            // Phí/Buổi
            _buildInfoRow(
              Icons.attach_money,
              lopHoc.hocPhi, // Đã có định dạng "vnd/Buoi" từ API
              Colors.grey,
            ),

            const SizedBox(height: 8),

            // Trạng thái + nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Trạng thái
                Row(
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      'Trạng thái: $status',
                      style: TextStyle(color: statusColor),
                    ),
                  ],
                ),
              ],
            ),

            // Hiển thị các nút bấm dựa trên trạng thái
            const Divider(height: 20),
            _buildActionButtons(context, lopHoc),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng các nút hành động (Xem đề nghị, Sửa, Đóng...)
  Widget _buildActionButtons(BuildContext context, LopHoc lopHoc) {
    String status = lopHoc.trangThai ?? '';

    // Hàm tạo kiểu cho nút
    ElevatedButton styledButton(
      String text,
      VoidCallback onPressed, [
      Color? color,
    ]) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
        ),
        child: Text(text),
      );
    }

    if (status == 'TimGiaSu') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // NÚT XEM ĐỀ NGHỊ MỚI
          styledButton('Xem đề nghị', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Điều hướng đến trang xem đề nghị, truyền ID lớp
                builder:
                    (context) =>
                        StudentClassProposalsScreen(lopHocId: lopHoc.maLop),
              ),
            );
          }, Colors.green),
          const SizedBox(width: 8),
          styledButton('Sửa', () {}),
          const SizedBox(width: 8),
          styledButton('Đóng', () {}, Colors.red),
        ],
      );
    }

    if (status == 'DangHoc') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [styledButton('Xem lịch', () {})],
      );
    }

    if (status == 'ChoDuyet') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          styledButton('Sửa', () {}),
          const SizedBox(width: 8),
          styledButton('Đóng', () {}, Colors.red),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
