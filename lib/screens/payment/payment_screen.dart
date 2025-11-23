import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giao_dich_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giao_dich_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';

class PaymentScreen extends StatefulWidget {
  final int lopYeuCauID;
  final double soTien;
  final int taiKhoanID;

  const PaymentScreen({
    super.key,
    required this.lopYeuCauID,
    required this.soTien,
    required this.taiKhoanID,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  final GiaoDichRepository _giaoDichRepo = GiaoDichRepository();
  final LopHocRepository _lopHocRepo = LopHocRepository();
  bool _isWaitingForPaymentReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForPaymentReturn) {
      _verifyPaymentStatus();
    }
  }

  // --- XỬ LÝ VNPAY (Giữ nguyên) ---
  Future<void> _verifyPaymentStatus() async {
    setState(() => _isLoading = true);
    try {
      final ApiResponse<LopHoc> response = await _lopHocRepo.getLopHocById(
        widget.lopYeuCauID,
      );
      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final lopHoc = response.data!;
        if (lopHoc.trangThaiThanhToan == 'DaThanhToan') {
          _isWaitingForPaymentReturn = false;
          _showSuccessAndExit("Thanh toán VNPAY thành công!");
        } else {
          _showRetryDialog();
        }
      } else {
        _showErrorSnackBar(
          "Không thể kiểm tra trạng thái: ${response.message}",
        );
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi kết nối: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Đang xử lý thanh toán"),
            content: const Text(
              "Hệ thống chưa nhận được kết quả. Vui lòng thử lại.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _isWaitingForPaymentReturn = false);
                },
                child: const Text(
                  "Hủy bỏ",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _verifyPaymentStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "Kiểm tra lại",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleVnPayPayment() async {
    setState(() => _isLoading = true);
    try {
      final res = await _giaoDichRepo.createVnPayUrl(
        lopYeuCauId: widget.lopYeuCauID,
        soTien: widget.soTien,
      );

      if (res.success && res.data != null) {
        final String paymentUrl = res.data!;
        final Uri uri = Uri.parse(paymentUrl);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          _isWaitingForPaymentReturn = true;
        } catch (e) {
          _showErrorSnackBar('Không thể mở trình duyệt: $e');
        }
      } else {
        _showErrorSnackBar(res.message);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi ứng dụng: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- [SỬA ĐỔI] XỬ LÝ MOMO (MÔ PHỎNG THÀNH CÔNG NGAY) ---
  Future<void> _handleMoMoPayment() async {
    setState(() => _isLoading = true);

    // Tạo model giao dịch
    final requestData = GiaoDichModel(
      lopYeuCauID: widget.lopYeuCauID,
      taiKhoanID: widget.taiKhoanID,
      soTien: widget.soTien,
      loaiGiaoDich: 'MoMo',
      ghiChu: 'Thanh toán phí nhận lớp ${widget.lopYeuCauID} (MoMo)',
    );

    try {
      // Gọi API tạo giao dịch (Backend đã cấu hình để tự set "Thành công")
      final response = await _giaoDichRepo.createGiaoDich(requestData);

      if (response.isSuccess) {
        // Thông báo thành công ngay lập tức
        _showSuccessAndExit('Thanh toán MoMo thành công!');
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm điều phối
  Future<void> _processPayment(String loaiGiaoDich) async {
    if (loaiGiaoDich == 'VNPAY') {
      await _handleVnPayPayment();
    } else if (loaiGiaoDich == 'MoMo') {
      await _handleMoMoPayment(); // Gọi hàm xử lý nhanh
    }
  }

  // Hàm chung hiển thị thành công và thoát
  void _showSuccessAndExit(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Đóng màn hình và trả về true để reload danh sách
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.grey200, height: 1),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTransactionInfoCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // VNPAY
                    _buildPaymentMethodTile(
                      icon: Icons.qr_code_2,
                      title: 'VNPAY-QR / Ví VNPAY',
                      subtitle: 'Quét mã hoặc dùng thẻ ATM/Visa',
                      color: Colors.blue,
                      onTap: () => _processPayment('VNPAY'),
                    ),

                    const SizedBox(height: 12),

                    // MOMO (Đã kích hoạt)
                    _buildPaymentMethodTile(
                      icon: Icons.account_balance_wallet,
                      title: 'Ví MoMo',
                      subtitle:
                          'Thanh toán nhanh (Thử nghiệm)', // Đổi text cho hợp lý
                      color: Colors.pink,
                      onTap: () => _processPayment('MoMo'),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTransactionInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text('Tổng thanh toán', style: TextStyle(color: AppColors.grey600)),
          const SizedBox(height: 8),
          Text(
            '${formatNumber(widget.soTien)} đ',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow('Mã lớp', '#${widget.lopYeuCauID}'),
          const SizedBox(height: 12),
          _buildInfoRow('Nội dung', 'Phí nhận lớp dạy kèm'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }
}
