// Giữ nguyên imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
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

  Color _getStatusColor(String? code) {
    if (code == 'DangHoc') return Colors.green;
    if (code == 'TimGiaSu') return Colors.orange;
    return Colors.grey;
  }

  String _getStatusText(String? code) {
    if (code == 'DangHoc') return 'Đang hoạt động';
    if (code == 'TimGiaSu') return 'Đang tìm gia sư';
    return 'Khác';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chi tiết lớp học',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(child: Text('Lỗi: $_errorMessage'));
    }
    if (_lopHoc == null) {
      return const Center(child: Text('Không tìm thấy lớp học.'));
    }

    final bool isTutor = widget.userRole == UserRole.tutor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isTutor)
                  Text(
                    _lopHoc!.tieuDeLop,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                if (!isTutor) const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          _lopHoc!.trangThai,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(_lopHoc!.trangThai),
                        style: TextStyle(
                          color: _getStatusColor(_lopHoc!.trangThai),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${formatNumber(toNumber(_lopHoc!.hocPhi))} đ/buổi',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Đăng ngày: ${_lopHoc!.ngayTao ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle("Thông tin chung"),

          _buildInfoRow(Icons.book_outlined, "Môn học", _lopHoc!.tenMon),
          _buildInfoRow(Icons.stairs_outlined, "Lớp", _lopHoc!.tenKhoiLop),
          _buildInfoRow(
            Icons.computer_outlined,
            "Hình thức",
            _lopHoc!.hinhThuc,
          ),
          _buildInfoRow(Icons.school_outlined, "Yêu cầu GV", _lopHoc!.doiTuong),
          _buildInfoRow(
            Icons.people_outline,
            "Số lượng HV",
            "${_lopHoc!.soLuong ?? 1}",
          ),

          const SizedBox(height: 24),
          _buildSectionTitle("Lịch học & Liên hệ"),

          _buildInfoRow(
            Icons.access_time,
            "Thời lượng",
            _lopHoc!.thoiLuong != null
                ? '${_lopHoc!.thoiLuong} phút/buổi'
                : null,
          ),
          _buildInfoRow(
            Icons.calendar_month_outlined,
            "Số buổi/tuần",
            _lopHoc!.soBuoiTuan?.toString(),
          ),
          _buildInfoRow(
            Icons.schedule,
            "Lịch mong muốn",
            _lopHoc!.lichHocMongMuon,
          ),

          if (isTutor) ...[
            _buildInfoRow(
              Icons.person_outline,
              "Người đăng",
              _lopHoc!.tenNguoiHoc,
            ),
            _buildInfoRow(Icons.phone_outlined, "SĐT", _lopHoc!.soDienThoai),
          ] else ...[
            _buildInfoRow(
              Icons.person_outline,
              "Gia sư",
              _lopHoc!.tenGiaSu ?? 'Chưa có',
            ),
          ],
          _buildInfoRow(Icons.location_on_outlined, "Địa chỉ", _lopHoc!.diaChi),

          const SizedBox(height: 24),
          _buildSectionTitle("Ghi chú"),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _lopHoc!.moTaChiTiet ?? 'Không có mô tả.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? "Chưa cập nhật",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
