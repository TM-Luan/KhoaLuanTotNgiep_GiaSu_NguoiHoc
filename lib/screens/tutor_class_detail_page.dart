import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';

class TutorClassDetailPage extends StatefulWidget {
  final int lopHocId;

  const TutorClassDetailPage({super.key, required this.lopHocId});

  @override
  State<TutorClassDetailPage> createState() => _TutorClassDetailPageState();
}

class _TutorClassDetailPageState extends State<TutorClassDetailPage> {
  final LopHocRepository _lopHocRepo = LopHocRepository();

  bool _isLoading = true;
  bool _isSubmitting = false;
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
        title: const Text('Chi tiết lớp học'),
        backgroundColor: Color(0xFF0865B3),
        elevation: 1,
      ),
      body: _buildBody(), // Gọi hàm xây dựng body
      bottomNavigationBar: _buildBottomButton(), // Nút "Đề nghị dạy"
    );
  }

  // Hàm xây dựng nội dung Body
  // Hàm xây dựng nội dung Body
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      // ... (code xử lý lỗi giữ nguyên) ...
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

    // === CODE ĐÃ SỬA LẠI ===
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: Colors.blueAccent,
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
                      label: Text(
                        _lopHoc!.trangThai ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Mã lớp
          Text(
            'Mã lớp: ${_lopHoc!.maLop}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

          // --- NGÀY TẠO MỚI THÊM VÀO ---
          const SizedBox(height: 8),
          Text(
            'Ngày đăng: ${_lopHoc!.ngayTao ?? "N/A"}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

          // --- KẾT THÚC PHẦN THÊM MỚI ---
          const Divider(height: 32),

          // Thông tin chính
          _buildDetailRow(Icons.person, 'Người đăng', _lopHoc!.tenNguoiHoc),
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

          // --- ID MỚI THÊM VÀO (NẾU BẠN MUỐN HIỂN THỊ) ---
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

          // --- KẾT THÚC PHẦN THÊM MỚI ---
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

  // Nút "Đề nghị dạy" ở cuối trang
  Widget? _buildBottomButton() {
    if (_isLoading || _lopHoc == null) return null; // Ẩn khi đang tải

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSendProposal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(double.infinity, 50), // Full-width
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child:
            _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Đề nghị dạy",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
      ),
    );
  }

  Future<void> _handleSendProposal() async {
    if (_lopHoc == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated ||
        authState.user.giaSuID == null ||
        authState.user.taiKhoanID == null) {
      _showSnack('Vui lòng đăng nhập bằng tài khoản gia sư để gửi đề nghị.', true);
      return;
    }

    final String? note = await _promptProposalNote();
    if (note == null) {
      return; // Người dùng hủy
    }

    setState(() {
      _isSubmitting = true;
    });

    final repo = context.read<YeuCauNhanLopRepository>();
    final response = await repo.giaSuGuiYeuCau(
      lopId: _lopHoc!.maLop,
      giaSuId: authState.user.giaSuID!,
      nguoiGuiTaiKhoanId: authState.user.taiKhoanID!,
      ghiChu: note.isEmpty ? null : note,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.isSuccess) {
      _showSnack('Đã gửi đề nghị dạy thành công.', false);
    } else {
      _showSnack(
        response.message.isNotEmpty
            ? response.message
            : 'Gửi đề nghị thất bại. Vui lòng thử lại.',
        true,
      );
    }
  }

  Future<String?> _promptProposalNote() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gửi đề nghị dạy'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Thêm ghi chú cho đề nghị (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').length > 500) {
                  return 'Ghi chú tối đa 500 ký tự';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Gửi đề nghị'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  void _showSnack(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
  }
}
