import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';

class StudentClassDetailScreen extends StatefulWidget {
  final int classId;

  const StudentClassDetailScreen({super.key, required this.classId});

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  final LopHocRepository _lopHocRepo = LopHocRepository();

  bool _isLoading = true;
  LopHoc? _lopHoc;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLopHocDetail();
  }

  String _getStatusText(String? code) {
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

  Color _getStatusColor(String? code) {
    switch (code) {
      case 'DangHoc':
        return Colors.green;
      case 'TimGiaSu':
        return Colors.orange;
      case 'ChoDuyet':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? code) {
    switch (code) {
      case 'DangHoc':
        return Icons.check_circle_outline;
      case 'TimGiaSu':
        return Icons.search;
      case 'ChoDuyet':
        return Icons.pending_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _fetchLopHocDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ApiResponse<LopHoc> response = await _lopHocRepo.getLopHocById(
      widget.classId,
    ); // Dùng widget.classId

    if (mounted) {
      if (response.isSuccess && response.data != null) {
        setState(() {
          _lopHoc = response.data!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết lớp học',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppTypography.appBarTitle,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  // Hàm xây dựng nội dung Body
  Widget _buildBody() {
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
                onPressed: _fetchLopHocDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lopHoc == null) {
      return const Center(child: Text('Không tìm thấy chi tiết lớp học.'));
    }

    // Hiển thị chi tiết khi có dữ liệu
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            _lopHoc!.tieuDeLop,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Phần Trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Trạng thái',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip đẹp, rõ chữ, đúng màu
                      IntrinsicWidth(
                        // Đảm bảo chip vừa đủ rộng
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _lopHoc!.trangThai,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(
                                _lopHoc!.trangThai,
                              ).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(_lopHoc!.trangThai),
                                size: 16,
                                color: _getStatusColor(_lopHoc!.trangThai),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusText(_lopHoc!.trangThai),
                                style: TextStyle(
                                  color: _getStatusColor(_lopHoc!.trangThai),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text(
            'Mã lớp: ${_lopHoc!.maLop}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày đăng: ${_lopHoc!.ngayTao ?? "N/A"}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const Divider(height: 32),

          // Thông tin chính
          _buildDetailRow(
            Icons.person,
            'Gia sư',
            _lopHoc!.tenGiaSu ?? 'Chưa có',
          ),
          _buildDetailRow(
            Icons.location_on,
            'Địa chỉ',
            _lopHoc!.diaChi ?? 'Chưa cập nhật',
          ),
          _buildDetailRow(Icons.attach_money, 'Học phí', _lopHoc!.hocPhi),

          // Thông tin chi tiết lớp
          _buildDetailRow(
            Icons.computer,
            'Hình thức',
            _lopHoc!.hinhThuc ?? 'N/A',
          ),
          _buildDetailRow(
            Icons.schedule,
            'Thời lượng',
            _lopHoc!.thoiLuong ?? 'N/A',
          ),
          _buildDetailRow(
            Icons.calendar_today,
            'Thời gian học',
            _lopHoc!.thoiGianHoc ?? 'N/A',
          ),
          _buildDetailRow(
            Icons.school,
            'Đối tượng',
            _lopHoc!.doiTuong ?? 'N/A',
          ),
          _buildDetailRow(
            Icons.people,
            'Số lượng',
            _lopHoc!.soLuong?.toString() ?? 'N/A',
          ),
          _buildDetailRow(
            Icons.book_outlined,
            'Môn học',
            _lopHoc!.tenMon ?? 'N/A',
          ),
          _buildDetailRow(
            Icons.stairs_outlined,
            'Khối lớp',
            _lopHoc!.tenKhoiLop ?? 'N/A',
          ),

          const Divider(height: 32),
          const Text(
            'Mô tả chi tiết',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _lopHoc!.moTaChiTiet ?? 'Không có mô tả chi tiết.',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  // Widget con để hiển thị từng dòng thông tin
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
