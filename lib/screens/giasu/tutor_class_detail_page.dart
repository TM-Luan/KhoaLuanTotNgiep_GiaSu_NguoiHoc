import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/untils/format_vnd.dart';

class TutorClassDetailPage extends StatefulWidget {
  final int lopHocId;

  const TutorClassDetailPage({super.key, required this.lopHocId});

  @override
  State<TutorClassDetailPage> createState() => _TutorClassDetailPageState();
}

class _TutorClassDetailPageState extends State<TutorClassDetailPage> {
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

    // Gọi hàm API chi tiết bằng ID
    final ApiResponse<LopHoc> response = await _lopHocRepo.getLopHocById(
      widget.lopHocId,
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
      body: _buildBody(), // Gọi hàm xây dựng body
      // bottomNavigationBar: _buildBottomButton(), // Nút "Đề nghị dạy" - đã bỏ để chỉ xem thông tin
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

    // === CHUYỂN ĐỔI TRẠNG THÁI ===
    final statusStyle = getTrangThaiStyle(_lopHoc!.trangThai);
    final String trangThaiHienThi = getTrangThaiVietNam(_lopHoc!.trangThai);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === TRẠNG THÁI TIẾNG VIỆT ===
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
                        trangThaiHienThi,
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

          // Các thông tin khác giữ nguyên...
          _buildDetailRow(Icons.person, 'Người đăng', _lopHoc!.tenNguoiHoc),
          _buildDetailRow(
            Icons.location_on,
            'Địa chỉ',
            _lopHoc!.diaChi ?? 'Chưa cập nhật',
          ),
          _buildDetailRow(
            Icons.attach_money,
            'Học phí',
            formatCurrency(_lopHoc!.hocPhi),
          ),
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
                width:
                    MediaQuery.of(context).size.width -
                    80, // Giúp text tự xuống dòng
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
