import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giao_dich_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giao_dich_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';

class PaymentScreen extends StatefulWidget {
  final int lopYeuCauID;
  final double soTien;
  final int taiKhoanID;

  const PaymentScreen({
    Key? key,
    required this.lopYeuCauID,
    required this.soTien,
    required this.taiKhoanID,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  final GiaoDichRepository _giaoDichRepo = GiaoDichRepository();

  // Logic xử lý thanh toán giữ nguyên
  Future<void> _processPayment(String loaiGiaoDich) async {
    setState(() {
      _isLoading = true;
    });

    final requestData = GiaoDichModel(
      lopYeuCauID: widget.lopYeuCauID,
      taiKhoanID: widget.taiKhoanID,
      soTien: widget.soTien,
      loaiGiaoDich: loaiGiaoDich,
      ghiChu: 'Thanh toán phí nhận lớp ${widget.lopYeuCauID}',
    );

    try {
      final ApiResponse<GiaoDichModel> response = await _giaoDichRepo
          .createGiaoDich(requestData);

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(response.message)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${response.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi ứng dụng: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng màu nền xám nhạt hiện đại
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, false),
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
                    // Phần 1: Thông tin tổng quan (Số tiền & Chi tiết)
                    _buildTransactionInfoCard(),

                    const SizedBox(height: 24),

                    // Phần 2: Tiêu đề chọn phương thức
                    Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phần 3: Danh sách các nút thanh toán
                    _buildPaymentMethodTile(
                      icon: Icons.qr_code_2, // Icon đại diện VNPAY/QR
                      title: 'VNPAY-QR',
                      subtitle: 'Quét mã để thanh toán nhanh',
                      color: Colors.blue,
                      onTap: () => _processPayment('VNPAY'),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethodTile(
                      icon: Icons.account_balance_wallet,
                      title: 'Ví MoMo',
                      subtitle: 'Thanh toán qua ví điện tử MoMo',
                      color: Colors.pink,
                      onTap: () => _processPayment('MoMo'),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethodTile(
                      icon: Icons.payment,
                      title: 'ZaloPay',
                      subtitle: 'Thanh toán qua ZaloPay',
                      color: Colors.green,
                      onTap: () => _processPayment('ZaloPay'),
                    ),

                    const SizedBox(height: 30),

                    // Cam kết bảo mật nhỏ ở dưới cùng
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Giao dịch được bảo mật và an toàn',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTransactionInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Tổng thanh toán',
            style: TextStyle(color: AppColors.grey600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatNumber(widget.soTien)} đ',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary, // Màu chủ đạo
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow('Mã lớp', '#${widget.lopYeuCauID}'),
                const SizedBox(height: 12),
                _buildInfoRow('Nội dung', 'Phí nhận lớp dạy kèm'),
                const SizedBox(height: 12),
                _buildInfoRow('Người thanh toán', 'ID: ${widget.taiKhoanID}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey600, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }
}
