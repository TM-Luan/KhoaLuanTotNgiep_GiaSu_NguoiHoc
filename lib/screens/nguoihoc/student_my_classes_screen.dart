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

class StudentMyClassesPage extends StatefulWidget {
  // [THÊM] Tham số chọn tab mặc định: 0=Đang học, 1=Đã học, 2=Tìm gia sư
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
    // [SỬA] Khởi tạo với initialIndex
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

  // ... (Phần còn lại của file giữ nguyên)
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lớp học của tôi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Đang Học'),
            Tab(text: 'Đã Học'),
            Tab(text: 'Tìm Gia Sư'),
          ],
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchClasses,
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildClassList(
                    _lopHocDangDay,
                    "Bạn chưa có lớp nào đang học",
                  ),
                  _buildClassList(_lopHocDaHoc, "Lịch sử lớp học trống"),
                  _buildClassList(
                    _lopHocTimGiaSu,
                    "Không có lớp nào đang tìm gia sư",
                  ),
                ],
              ),
    );
  }

  Widget _buildClassList(List<LopHoc> list, String emptyMsg) {
    if (list.isEmpty) {
      return Center(
        child: Text(emptyMsg, style: const TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchClasses,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildClassCard(list[index]),
      ),
    );
  }

  Widget _buildClassCard(LopHoc lop) {
    final statusText = getTrangThaiVietNam(lop.trangThai);
    final style = getTrangThaiStyle(lop.trangThai);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lop.tieuDeLop,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            const SizedBox(height: 12),
            Text('Môn: ${lop.tenMon ?? "Chưa cập nhật"}'),
            Text('Học phí: ${formatNumber(toNumber(lop.hocPhi))} đ/buổi'),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(lop),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(LopHoc lop) {
    if (lop.trangThai == 'TimGiaSu') {
      return [
        TextButton(
          onPressed: () => _confirmCloseClass(lop),
          child: const Text('Đóng lớp', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddClassPage(classId: lop.maLop),
                ),
              ).then((v) => v == true ? _fetchClasses() : null),
          child: const Text('Sửa'),
        ),
        ElevatedButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => StudentClassProposalsScreen(lopHocId: lop.maLop),
                ),
              ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
          child: const Text(
            'Xem đề nghị',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ];
    }
    return [
      TextButton(
        onPressed:
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
        child: const Text('Chi tiết'),
      ),
    ];
  }

  Future<void> _confirmCloseClass(LopHoc lop) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận đóng lớp'),
            content: const Text(
              'Bạn có chắc chắn muốn đóng lớp học này không? Hành động này sẽ xóa lớp khỏi danh sách tìm kiếm.',
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
