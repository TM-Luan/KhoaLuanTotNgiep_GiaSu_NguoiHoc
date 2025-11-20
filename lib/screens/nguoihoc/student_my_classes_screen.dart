import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/add_class_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_class_proposals_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_info_row.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/complaint_form_screen.dart';
// Import trang lịch học
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_schedule_screen.dart';

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
  List<LopHoc> _lopHocDangDay = []; // Biến này chứa danh sách Đang Học

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
      _lopHocTimGiaSu = []; 
      _lopHocDangDay = []; 
    });

    try {
      final response = await _lopHocRepo.getLopHocCuaNguoiHoc();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final List<LopHoc> tatCaLopCuaToi = response.data!;

        setState(() {
          _lopHocTimGiaSu =
              tatCaLopCuaToi
                  .where((lop) => lop.trangThai == 'TimGiaSu')
                  .toList();

          _lopHocDangDay =
              tatCaLopCuaToi
                  .where((lop) => lop.trangThai == 'DangHoc')
                  .toList();
        });
      } else {
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
              // === THAY ĐỔI Ở ĐÂY: Đảo thứ tự Tab ===
              tabs: const [
                Tab(text: 'Đang Học'), 
                Tab(text: 'Đang Tìm Gia Sư'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isAdded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClassPage()),
          );
          if (isAdded == true) {
            _fetchClasses();
          }
        },
        backgroundColor: AppColors.primary, 
        tooltip: 'Thêm Lớp', 
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

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

    // === THAY ĐỔI Ở ĐÂY: Đảo thứ tự nội dung tương ứng với Tab ===
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1: Đang Học (Hiển thị đầu tiên)
        _buildClassListView(
          _lopHocDangDay, 
          'Bạn chưa có lớp nào đang học.',
        ),
        // Tab 2: Đang Tìm Gia Sư
        _buildClassListView(
          _lopHocTimGiaSu,
          'Không có lớp nào đang tìm gia sư.',
        ),
      ],
    );
  }

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

    final Color cardColor = Colors.blue.shade50;
    final Color statusColor = Colors.blue.shade100;
    final Color textColor = Colors.blue.shade700;
    final IconData statusIcon = Icons.send_outlined;

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
              colors: [cardColor, Colors.white], 
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
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
                      margin: const EdgeInsets.only(left: 8),
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
                  value: '${formatNumber(toNumber(lopHoc.hocPhi))} VNĐ/Buổi',
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

                // --- FOOTER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 12),
                    _buildActionButtons(
                      context,
                      lopHoc,
                    ), 
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LopHoc lopHoc) {
    String status = lopHoc.trangThai ?? '';

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
          styledButton('Xem đề nghị', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        StudentClassProposalsScreen(lopHocId: lopHoc.maLop),
              ),
            );
          }, Colors.green),
          const SizedBox(width: 8),
          styledButton('Sửa', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddClassPage(classId: lopHoc.maLop),
              ),
            ).then((isSuccess) {
              if (isSuccess == true) {
                _fetchClasses();
              }
            });
          }),
          const SizedBox(width: 8),
          styledButton('Đóng', () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.red.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade400,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Đóng lớp này?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Lớp sẽ bị xóa vĩnh viễn khỏi danh sách của bạn. Hành động này không thể hoàn tác!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.close),
                              label: const Text('Hủy'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context); 
                                final rootContext = this.context;
                                final response = await _lopHocRepo.deleteLopHoc(
                                  lopHoc.maLop,
                                );

                                if (!mounted) return; 

                                if (response.success) {
                                  ScaffoldMessenger.of(
                                    rootContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã đóng lớp thành công!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _fetchClasses();
                                } else {
                                  ScaffoldMessenger.of(
                                    rootContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: ${response.message}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Đóng lớp'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }, Colors.red),
        ],
      );
    }

    if (status == 'DangHoc') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          styledButton(
            'Khiếu nại',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => ComplaintFormScreen(
                        lopId: lopHoc.maLop, 
                      ),
                ),
              );
            },
            Colors.red.shade400, 
          ),
          const SizedBox(width: 8),
          styledButton('Xem lịch', () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LearnerSchedulePage(),
              ),
            );
          }),
        ],
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