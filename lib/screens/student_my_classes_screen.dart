// FILE: student_my_classes_screen.dart
// (Viết lại toàn bộ)

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/add_class_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_class_detail_screen.dart';
// TODO: Tạo file này ở bước 5
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_class_proposals_screen.dart'; 

class StudentMyClassesPage extends StatefulWidget {
  const StudentMyClassesPage({super.key});

  @override
  State<StudentMyClassesPage> createState() => _StudentMyClassesPageState();
}

class _StudentMyClassesPageState extends State<StudentMyClassesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LopHocRepository _lopHocRepo = LopHocRepository();

  bool _isLoading = true;
  String? _errorMessage;

  // Danh sách cho từng tab
  List<LopHoc> _lopHocTimGiaSu = [];
  List<LopHoc> _lopHocDangDay = [];
  // Bạn có thể thêm các list khác (Chờ duyệt, Hoàn thành...) nếu muốn

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với 2 tab
    _tabController = TabController(length: 2, vsync: this);
    _fetchClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hàm gọi API cho tất cả các tab
  Future<void> _fetchClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gọi API song song cho các trạng thái
      final responses = await Future.wait([
        _lopHocRepo.getLopHocByTrangThai('TimGiaSu'),
        _lopHocRepo.getLopHocByTrangThai('DangHoc'),
      ]);

      if (!mounted) return;

      // Xử lý response cho "Tìm Gia Sư"
      if (responses[0].isSuccess && responses[0].data != null) {
        _lopHocTimGiaSu = responses[0].data!;
      }

      // Xử lý response cho "Đang Dạy"
      if (responses[1].isSuccess && responses[1].data != null) {
        _lopHocDangDay = responses[1].data!;
      }

      // Kiểm tra nếu có bất kỳ lỗi nào
      if (!responses[0].isSuccess) {
        _errorMessage = responses[0].message;
      } else if (!responses[1].isSuccess) {
        _errorMessage = responses[1].message;
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
        title: const Text(
          'LỚP CỦA TÔI',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Điều hướng đến trang AddClassPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddClassPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Thêm Lớp'),
            ),
          )
        ],
        // Thêm TabBar vào AppBar
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Đang Tìm Gia Sư'),
            Tab(text: 'Đang Dạy'),
            // Bạn có thể thêm các tab khác ở đây
          ],
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
        _buildClassListView(_lopHocTimGiaSu, 'Không có lớp nào đang tìm gia sư.'),
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
            builder: (context) => StudentClassDetailScreen(classId: lopHoc.maLop),
            // TODO: Đảm bảo 'StudentClassDetailScreen' nhận 'classId'
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
              color: Colors.black.withOpacity(0.1),
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
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade700),
              ],
            ),
            const SizedBox(height: 8),

            // Tên gia sư (lấy từ API)
            _buildInfoRow(
              Icons.person, 
              lopHoc.tenGiaSu ?? 'Chưa có gia sư', // Dùng dữ liệu mới
              Colors.grey
            ),
            
            // Địa chỉ
            _buildInfoRow(
              Icons.location_on, 
              lopHoc.diaChi ?? 'Chưa cập nhật', 
              Colors.grey
            ),
            
            // Phí/Buổi
            _buildInfoRow(
              Icons.attach_money,
              lopHoc.hocPhi, // Đã có định dạng "vnd/Buoi" từ API
              Colors.grey
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
    ElevatedButton _styledButton(String text, VoidCallback onPressed, [Color? color]) {
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
          _styledButton('Xem đề nghị', () {
             Navigator.push(
              context,
              MaterialPageRoute(
                // Điều hướng đến trang xem đề nghị, truyền ID lớp
                builder: (context) => StudentClassProposalsScreen(lopHocId: lopHoc.maLop),
              ),
            );
          }, Colors.green),
          const SizedBox(width: 8),
          _styledButton('Sửa', () { /* TODO: Logic sửa */ }),
          const SizedBox(width: 8),
          _styledButton('Đóng', () { /* TODO: Logic đóng */ }, Colors.red),
        ],
      );
    } 
    
    if (status == 'DangHoc') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _styledButton('Xem lịch', () { /* TODO: Logic xem lịch */ }),
        ],
      );
    }
    
    if (status == 'ChoDuyet') {
       return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _styledButton('Sửa', () { /* TODO: Logic sửa */ }),
          const SizedBox(width: 8),
          _styledButton('Đóng', () { /* TODO: Logic đóng */ }, Colors.red),
        ],
      );
    }

    // Trạng thái Hoàn thành, Hủy...
    return const SizedBox.shrink(); // Không hiển thị nút nào
  }
}