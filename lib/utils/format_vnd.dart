import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final numberFormat = NumberFormat.decimalPattern('en_US');

String formatNumber(double? value) {
  if (value == null) return '0';
  return numberFormat.format(value);
}

double? tinhPhiNhanLop({
  required double? hocPhiMotBuoi,
  required int? soBuoiMotTuan,
}) {
  if (hocPhiMotBuoi == null || soBuoiMotTuan == null) return null;
  const double tyLePhi = 0.3; // 30%
  const int soTuan = 4; // 1 tháng = 4 tuần
  final phi = hocPhiMotBuoi * soBuoiMotTuan * soTuan * tyLePhi;
  return phi.roundToDouble();
}

double? toNumber(String? input) {
  if (input == null || input.isEmpty) return null;
  final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

// --- [CẬP NHẬT] HÀM CHUYỂN ĐỔI TRẠNG THÁI SANG TIẾNG VIỆT ---
String getTrangThaiVietNam(String? trangThai) {
  if (trangThai == null) return 'Không xác định';
  switch (trangThai) {
    // Trạng thái Lớp học
    case 'TimGiaSu':
      return 'Đang tìm gia sư';
    case 'ChoDuyet':
      return 'Chờ duyệt';
    case 'DangHoc':
      return 'Đang học';
    case 'HoanThanh':
      return 'Hoàn thành';
    case 'DaKetThuc':
      return 'Đã kết thúc';
    case 'Huy':
      return 'Đã hủy';

    // Trạng thái Lịch học
    case 'SapToi':
    case 'ChuaDienRa':
      return 'Sắp tới';
    case 'DangDay':
      return 'Đang diễn ra';
    case 'DaHoc':
      return 'Đã xong';

    // Trạng thái Yêu cầu (Lời mời/Đề nghị)
    case 'Pending':
      return 'Chờ phản hồi';
    case 'Accepted':
      return 'Đã chấp nhận';
    case 'Rejected':
      return 'Đã từ chối';
    case 'Cancelled':
      return 'Đã hủy';

    // Trạng thái Thanh toán
    case 'DaThanhToan':
      return 'Đã thanh toán';
    case 'ChuaThanhToan':
      return 'Chưa thanh toán';

    default:
      return trangThai; // Trả về gốc nếu không khớp
  }
}

// --- [CẬP NHẬT] HÀM LẤY MÀU SẮC THEO TRẠNG THÁI ---
Map<String, dynamic> getTrangThaiStyle(String? trangThai) {
  switch (trangThai) {
    case 'DangHoc':
    case 'HoanThanh':
    case 'DaKetThuc':
    case 'Accepted':
    case 'DaThanhToan':
    case 'DaHoc':
      return {
        'color': Colors.green.shade700,
        'bgColor': Colors.green.shade50,
        'icon': Icons.check_circle_outline,
      };

    case 'TimGiaSu':
    case 'SapToi':
    case 'ChuaDienRa':
      return {
        'color': Colors.blue.shade700,
        'bgColor': Colors.blue.shade50,
        'icon': Icons.search,
      };

    case 'ChoDuyet':
    case 'Pending':
    case 'DangDay':
      return {
        'color': Colors.orange.shade700,
        'bgColor': Colors.orange.shade50,
        'icon': Icons.hourglass_empty,
      };

    case 'Huy':
    case 'Cancelled':
    case 'Rejected':
    case 'ChuaThanhToan':
      return {
        'color': Colors.red.shade700,
        'bgColor': Colors.red.shade50,
        'icon': Icons.cancel_outlined,
      };

    default:
      return {
        'color': Colors.grey.shade700,
        'bgColor': Colors.grey.shade100,
        'icon': Icons.info_outline,
      };
  }
}
