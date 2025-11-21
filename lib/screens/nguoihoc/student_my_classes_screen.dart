import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/add_class_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_class_proposals_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/complaint_form_screen.dart';
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
  late StreamSubscription _proposalUpdateSubscription;
  bool _isLoading = true;
  String? _errorMessage;
  List<LopHoc> _lopHocTimGiaSu = [];
  List<LopHoc> _lopHocDangDay = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _proposalUpdateSubscription = GlobalNotificationService()
        .proposalUpdateStream
        .listen((event) => _fetchClasses());
    _fetchClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _proposalUpdateSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lopHocTimGiaSu = [];
      _lopHocDangDay = [];
    });
    try {
      final response = await _lopHocRepo.getLopHocCuaNguoiHoc();
      if (mounted && response.isSuccess && response.data != null) {
        final all = response.data!;
        setState(() {
          _lopHocTimGiaSu =
              all.where((lop) => lop.trangThai == 'TimGiaSu').toList();
          _lopHocDangDay =
              all.where((lop) => lop.trangThai == 'DangHoc').toList();
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '$e';
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lớp học',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Đang Học'), Tab(text: 'Tìm Gia Sư')],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isAdded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddClassPage()),
          );
          if (isAdded == true) _fetchClasses();
        },
        backgroundColor: AppColors.primary,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: TextButton(
                  onPressed: _fetchClasses,
                  child: const Text('Thử lại'),
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildClassListView(
                    _lopHocDangDay,
                    'Bạn chưa có lớp nào đang học.',
                  ),
                  _buildClassListView(
                    _lopHocTimGiaSu,
                    'Không có lớp nào đang tìm gia sư.',
                  ),
                ],
              ),
    );
  }

  Widget _buildClassListView(List<LopHoc> list, String emptyMsg) {
    if (list.isEmpty) return _buildEmptyState(emptyMsg);
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildClassCard(context, list[index]),
    );
  }

  Widget _buildClassCard(BuildContext context, LopHoc lopHoc) {
    final status = lopHoc.trangThai ?? 'N/A';
    final isLearning = status == 'DangHoc';
    final accentColor = isLearning ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ClassDetailScreen(
                    classId: lopHoc.maLop,
                    userRole: UserRole.student,
                  ),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: accentColor), // Colored Strip
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                lopHoc.tieuDeLop,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isLearning ? 'Đang học' : 'Tìm gia sư',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          Icons.person_outline,
                          lopHoc.tenGiaSu ?? 'Chưa có gia sư',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoItem(
                          Icons.attach_money,
                          '${formatNumber(toNumber(lopHoc.hocPhi))} đ/Buổi',
                        ),

                        const SizedBox(height: 16),
                        Divider(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 12),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _buildActions(context, lopHoc, status),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    LopHoc lopHoc,
    String status,
  ) {
    Widget btn(
      String label,
      VoidCallback onTap, {
      bool isPrimary = false,
      bool isDanger = false,
    }) {
      Color color =
          isDanger
              ? Colors.red
              : (isPrimary ? AppColors.primary : Colors.grey.shade700);
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isPrimary
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDanger
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (status == 'TimGiaSu') {
      return [
        btn(
          'Đóng lớp',
          () => _confirmCloseClass(context, lopHoc),
          isDanger: true,
        ),
        const SizedBox(width: 8),
        btn(
          'Sửa',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddClassPage(classId: lopHoc.maLop),
            ),
          ).then((v) => v == true ? _fetchClasses() : null),
        ),
        const SizedBox(width: 8),
        btn(
          'Đề nghị',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => StudentClassProposalsScreen(lopHocId: lopHoc.maLop),
            ),
          ),
          isPrimary: true,
        ),
      ];
    } else {
      return [
        btn(
          'Khiếu nại',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintFormScreen(lopId: lopHoc.maLop),
            ),
          ),
          isDanger: true,
        ),
        const SizedBox(width: 8),
        btn(
          'Xem lịch',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LearnerSchedulePage()),
          ),
          isPrimary: true,
        ),
      ];
    }
  }

  Future<void> _confirmCloseClass(BuildContext context, LopHoc lop) {
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Đóng lớp học?'),
            content: const Text('Hành động này không thể hoàn tác.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final res = await _lopHocRepo.deleteLopHoc(lop.maLop);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res.success ? 'Đã đóng' : res.message),
                        backgroundColor:
                            res.success ? Colors.green : Colors.red,
                      ),
                    );
                    if (res.success) _fetchClasses();
                  }
                },
                child: const Text(
                  'Đóng lớp',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
