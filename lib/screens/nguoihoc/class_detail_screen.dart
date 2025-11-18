import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';

enum UserRole { tutor, student }

class ClassDetailScreen extends StatefulWidget {
  final int classId;
  final UserRole userRole;

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.userRole,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final LopHocRepository _lopHocRepo = LopHocRepository();

  bool _isLoading = true;
  LopHoc? _lopHoc;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLopHocDetail();
  }

  Future<void> _fetchLopHocDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ApiResponse<LopHoc> response = await _lopHocRepo.getLopHocById(
      widget.classId,
    );

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

  // === HÀM XỬ LÝ TRẠNG THÁI CHUNG ===
  Map<String, dynamic> getTrangThaiStyle(String? trangThaiCode) {
    switch (trangThaiCode) {
      case 'DangHoc':
        return {
          'text': 'Đang hoạt động',
          'color': Colors.green,
          'icon': Icons.check_circle_outline,
          'bgColor': Colors.green.withValues(alpha: 0.15),
        };
      case 'TimGiaSu':
        return {
          'text': 'Tìm gia sư',
          'color': Colors.orange,
          'icon': Icons.search,
          'bgColor': Colors.orange.withValues(alpha: 0.15),
        };

      default:
        return {
          'text': 'Không xác định',
          'color': Colors.grey,
          'icon': Icons.info_outline,
          'bgColor': Colors.grey.withValues(alpha: 0.15),
        };
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

    // === XỬ LÝ HIỂN THỊ THEO ROLE ===
    final statusStyle = getTrangThaiStyle(_lopHoc!.trangThai);
    final bool isTutor = widget.userRole == UserRole.tutor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === TIÊU ĐỀ (chỉ hiển thị cho học sinh) ===
          if (!isTutor) ...[
            Text(
              _lopHoc!.tieuDeLop,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],

          // === TRẠNG THÁI ===
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  statusStyle['icon'],
                  color: statusStyle['color'],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trạng thái',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      avatar: Icon(
                        statusStyle['icon'],
                        size: 16,
                        color: statusStyle['color'],
                      ),
                      label: Text(
                        statusStyle['text'],
                        style: TextStyle(
                          color: statusStyle['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: statusStyle['bgColor'],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: statusStyle['color'].withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
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

          // === THÔNG TIN CHÍNH - HIỂN THỊ THEO ROLE ===
          if (isTutor)
            _buildDetailRow(Icons.person, 'Người đăng', _lopHoc!.tenNguoiHoc),
          if (!isTutor)
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
          _buildDetailRow(
            Icons.attach_money,
            'Học phí',
            '${formatNumber(toNumber(_lopHoc!.hocPhi))} VNĐ/Buổi',
          ),

          // === THÔNG TIN CHI TIẾT LỚP ===
          _buildDetailRow(
            Icons.computer,
            'Hình thức',
            _lopHoc!.hinhThuc ?? 'N/A',
          ),

          _buildDetailRow(
            Icons.schedule,
            'Thời lượng / buổi', // Sửa text
            _lopHoc!.thoiLuong != null
                ? '${_lopHoc!.thoiLuong} phút/buổi'
                : 'N/A',
          ),

          // SỬA: Thay thế 'Thời gian học' bằng 2 trường mới
          _buildDetailRow(
            Icons.calendar_today_outlined, // Icon mới
            'Số buổi / tuần',
            _lopHoc!.soBuoiTuan?.toString() ?? 'Chưa cập nhật',
          ),
          _buildDetailRow(
            Icons.access_time_outlined, // Icon mới
            'Lịch học mong muốn',
            _lopHoc!.lichHocMongMuon ?? 'Chưa cập nhật',
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
                // SỬA: Thêm kiểm tra 'isEmpty'
                child: Text(
                  (value.isEmpty) ? 'Chưa cập nhật' : value,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
