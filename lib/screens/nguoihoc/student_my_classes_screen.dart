import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/add_class_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/class_detail.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_class_proposals_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/untils/format_vnd.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_info_row.dart';

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
          print(
            '🔔 Student screen nhận notification proposal update: ${event.type}, classId: ${event.classId}',
          );
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
          _lopHocTimGiaSu =
              tatCaLopCuaToi
                  .where(
                    (lop) =>
                        lop.trangThai == 'TimGiaSu' ||
                        lop.trangThai == 'ChoDuyet',
                  )
                  .toList();

          _lopHocDangDay =
              tatCaLopCuaToi
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
                    MaterialPageRoute(
                      builder: (context) => const AddClassPage(),
                    ),
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
              tabs: const [Tab(text: 'Đang Tìm Gia Sư'), Tab(text: 'Đang Học')],
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

  Widget _buildClassCard(BuildContext context, LopHoc lopHoc) {
    // Xác định trạng thái
    final String statusCode = lopHoc.trangThai ?? 'N/A';

    String getStatusText(String code) {
      switch (code) {
        case 'DangHoc':
          return 'Đang học';
        case 'TimGiaSu':
          return 'Tìm gia sư';
        case 'ChoDuyet':
          return 'Chờ duyệt';
        default:
          return 'Không xác định';
      }
    }

    // DÙNG MÀU XANH DƯƠNG GIỐNG HỆT CARD "GIA SƯ GỬI YÊU CẦU"
    final Color cardColor = Colors.blue.shade50;
    final Color statusColor = Colors.blue.shade100;
    final Color textColor = Colors.blue.shade700;
    final IconData statusIcon =
        Icons.send_outlined; // Giống icon khi Gia sư gửi

    final statusText = getStatusText(statusCode);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ClassDetailScreen(
                  classId: lopHoc.maLop,
                  userRole: UserRole.student,
                ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardColor, Colors.white], // Xanh nhạt → trắng
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER (GIỐNG HỆT CARD GIA SƯ GỬI) ---
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(statusIcon, color: textColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lopHoc.tieuDeLop,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // --- Thông tin lớp ---
                InfoRow(
                  icon: Icons.person,
                  label: 'Gia sư',
                  value: lopHoc.tenGiaSu ?? 'Chưa có gia sư',
                ),
                const SizedBox(height: 6),
                InfoRow(
                  icon: Icons.attach_money,
                  label: 'Học phí',
                  value: formatCurrency(lopHoc.hocPhi),
                ),
                if (lopHoc.diaChi?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  InfoRow(
                    icon: Icons.location_on_rounded,
                    label: 'Địa chỉ',
                    value: lopHoc.diaChi!,
                  ),
                ],

                const SizedBox(height: 12),

                // --- FOOTER (GIỐNG HỆT CARD GIA SƯ) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 12),
                    _buildActionButtons(
                      context,
                      lopHoc,
                    ), // Giữ nguyên chức năng
                  ],
                ),
              ],
            ),
          ),
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
