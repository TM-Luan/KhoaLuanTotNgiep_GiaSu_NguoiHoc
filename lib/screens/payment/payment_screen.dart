// file: lib/screens/payment_screen.dart (HOÀN CHỈNH)

import 'dart:async'; // Thêm import này để dùng Future.delayed
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
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

  Future<void> _processPayment(String loaiGiaoDich) async {
    setState(() {
      _isLoading = true;
    });

    // 1. Tạo đối tượng request model
    final requestData = GiaoDichModel(
      lopYeuCauID: widget.lopYeuCauID,
      taiKhoanID: widget.taiKhoanID,
      soTien: widget.soTien,
      loaiGiaoDich: loaiGiaoDich,
      ghiChu: 'Thanh toán phí nhận lớp ${widget.lopYeuCauID}',
    );

    // Debug print
    print('--- [DEBUG] ĐANG GỬI THANH TOÁN ---');
    print('LopYeuCauID: ${requestData.lopYeuCauID}');
    print('TaiKhoanID: ${requestData.taiKhoanID}');
    print('-------------------------------------');

    try {
      // 2. Gọi Repository
      final ApiResponse<GiaoDichModel> response = await _giaoDichRepo
          .createGiaoDich(requestData);

      if (!mounted) return;

      // 3. Xử lý kết quả
      if (response.isSuccess && response.data != null) {
        // === SỬA ĐỔI: HIỂN THỊ THÔNG BÁO THÀNH CÔNG ===
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // === ⭐️ SỬA LỖI: TỰ ĐỘNG ĐÓNG VÀ TRẢ VỀ 'true' ⭐️ ===
        // Đóng màn hình và trả kết quả 'true' về
        // Thêm 1 chút delay để người dùng kịp thấy SnackBar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true); // true = Báo thanh toán thành công
          }
        });
        // ===================================================
      } else {
        // HIỂN THỊ THÔNG BÁO LỖI TỪ SERVER
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${response.message}'), // Lấy lỗi từ API
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // HIỂN THỊ LỖI NẾU CÓ LỖI LẬP TRÌNH
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi ứng dụng: $e'),
          backgroundColor: Colors.red,
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

  // ... (Phần còn lại của file: build() và _buildPaymentButton không thay đổi) ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thanh toán phí nhận lớp',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: AppTypography.appBarTitle,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.background),
          // Sửa: pop(false) để báo là hủy/thất bại
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phí nhận lớp',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${formatNumber(widget.soTien)} VNĐ',
                              style: Theme.of(
                                context,
                              ).textTheme.displaySmall?.copyWith(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPaymentButton(
                      icon: Icons.payment,
                      label: 'Thanh toán VNPAY',
                      onTap: () => _processPayment('VNPAY'),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentButton(
                      icon: Icons.account_balance_wallet,
                      label: 'Thanh toán MoMo',
                      color: Colors.pink[300],
                      onTap: () => _processPayment('MoMo'),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentButton(
                      icon: Icons.wallet_giftcard,
                      label: 'Thanh toán ZaloPay',
                      color: Colors.blue[800],
                      onTap: () => _processPayment('ZaloPay'),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPaymentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color ?? Colors.blue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
          gradient:
              color == null
                  ? const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                  )
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
