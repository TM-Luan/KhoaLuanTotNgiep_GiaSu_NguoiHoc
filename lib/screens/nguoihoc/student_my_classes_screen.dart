// file: lib/screens/nguoihoc/student_my_classes_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/add_class_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/complaint_form_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/student_class_proposals_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';

class StudentMyClassesPage extends StatefulWidget {
  final int initialTabIndex;

  const StudentMyClassesPage({super.key, this.initialTabIndex = 0});

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
  List<LopHoc> _lopHocDaHoc = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

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
      _lopHocDaHoc = [];
    });
    try {
      final response = await _lopHocRepo.getLopHocCuaNguoiHoc();
      if (mounted && response.isSuccess && response.data != null) {
        final all = response.data!;
        setState(() {
          _lopHocTimGiaSu =
              all
                  .where(
                    (lop) =>
                        lop.trangThai == 'TimGiaSu' ||
                        lop.trangThai == 'ChoDuyet',
                  )
                  .toList();
          _lopHocDangDay =
              all.where((lop) => lop.trangThai == 'DangHoc').toList();
          _lopHocDaHoc =
              all
                  .where(
                    (lop) =>
                        lop.trangThai == 'DaKetThuc' ||
                        lop.trangThai == 'HoanThanh' ||
                        lop.trangThai == 'Huy',
                  )
                  .toList();
        });
      } else {
        setState(() => _errorMessage = response.message);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Lỗi kết nối: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sạch
      appBar: AppBar(
        title: const Text(
          'Lớp học của tôi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        // --- CUSTOM TAB BAR STYLE ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              indicatorPadding: const EdgeInsets.all(4),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Đang Học'),
                Tab(text: 'Đã Học'),
                Tab(text: 'Tìm Gia Sư'),
              ],
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildClassList(
                    _lopHocDangDay,
                    "Bạn chưa có lớp nào đang học",
                    Icons.school_outlined,
                  ),
                  _buildClassList(
                    _lopHocDaHoc,
                    "Lịch sử lớp học trống",
                    Icons.history_edu_outlined,
                  ),
                  _buildClassList(
                    _lopHocTimGiaSu,
                    "Không có lớp nào đang tìm gia sư",
                    Icons.search_off_outlined,
                  ),
                ],
              ),
    );
  }

  Widget _buildClassList(List<LopHoc> list, String emptyMsg, IconData icon) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchClasses,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildClassCard(list[index]),
      ),
    );
  }

  // --- MODERN CARD STYLE ---
  Widget _buildClassCard(LopHoc lop) {
    final statusText = getTrangThaiVietNam(lop.trangThai);
    final style = getTrangThaiStyle(lop.trangThai);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tên lớp & Trạng thái
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lop.tieuDeLop,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã lớp: ${lop.maLop}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: style['bgColor'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: style['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // Body: Thông tin chi tiết
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.book_outlined,
                  "Môn học",
                  lop.tenMon ?? "Chưa cập nhật",
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.monetization_on_outlined,
                  "Học phí",
                  '${formatNumber(toNumber(lop.hocPhi))} đ/buổi',
                  valueColor: Colors.black87,
                  isBold: true,
                ),
                if (lop.tenGiaSu != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person_outline, "Gia sư", lop.tenGiaSu!),
                ],
              ],
            ),
          ),

          // Footer: Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(lop),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(LopHoc lop) {
    if (lop.trangThai == 'TimGiaSu' || lop.trangThai == 'ChoDuyet') {
      return [
        _buildSmallButton(
          label: 'Đóng lớp',
          color: Colors.red.shade50,
          textColor: Colors.red,
          onTap: () => _confirmCloseClass(lop),
        ),
        const SizedBox(width: 8),
        _buildSmallButton(
          label: 'Sửa',
          color: Colors.grey.shade100,
          textColor: Colors.black87,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddClassPage(classId: lop.maLop),
                ),
              ).then((v) => v == true ? _fetchClasses() : null),
        ),
        const SizedBox(width: 8),
        _buildSmallButton(
          label: 'Đề nghị',
          color: AppColors.primary,
          textColor: Colors.white,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => StudentClassProposalsScreen(lopHocId: lop.maLop),
                ),
              ),
        ),
      ];
    }
    if (lop.trangThai == 'DangHoc') {
      return [
        _buildSmallButton(
          label: 'Xem chi tiết',
          color: Colors.grey.shade100,
          textColor: Colors.black87,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ClassDetailScreen(
                        classId: lop.maLop,
                        userRole: UserRole.student,
                      ),
                ),
              ),
        ),
        const SizedBox(width: 8),
        _buildSmallButton(
          label: 'Khiếu nại',
          color: Colors.orange.shade50,
          textColor: Colors.orange.shade700,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComplaintFormScreen(lopId: lop.maLop),
                ),
              ),
        ),
      ];
    }
    return [
      _buildSmallButton(
        label: 'Xem chi tiết',
        color: Colors.grey.shade100,
        textColor: Colors.black87,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ClassDetailScreen(
                      classId: lop.maLop,
                      userRole: UserRole.student,
                    ),
              ),
            ),
      ),
    ];
  }

  Widget _buildSmallButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(_errorMessage ?? "Đã có lỗi xảy ra"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchClasses,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Thử lại", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCloseClass(LopHoc lop) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận đóng lớp'),
            content: const Text(
              'Hành động này sẽ xóa lớp khỏi danh sách tìm kiếm.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Đóng lớp',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final res = await _lopHocRepo.deleteLopHoc(lop.maLop);
      if (mounted) {
        if (res.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đóng lớp thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchClasses();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${res.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
