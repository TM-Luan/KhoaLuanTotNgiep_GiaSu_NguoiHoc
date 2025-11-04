import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: 'VNĐ/Buổi',
);
String formatCurrency(String? amount) {
  // Nếu null, rỗng, hoặc không parse được → trả về mặc định
  if (amount == null || amount.isEmpty) {
    return 'Chưa có';
  }

  final double? value = double.tryParse(
    amount.replaceAll(RegExp(r'[^\d]'), ''),
  ); // Xóa ký tự không phải số
  if (value == null) {
    return amount; // Nếu không phải số, giữ nguyên (ví dụ: "Miễn phí")
  }

  return currencyFormat.format(value);
}

String getTrangThaiVietNam(String? trangThai) {
  switch (trangThai) {
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

Map<String, dynamic> getTrangThaiStyle(String? trangThai) {
  switch (trangThai) {
    case 'DangHoc':
      return {
        'color': Colors.green.shade700,
        'bgColor': Colors.green.shade50,
        'icon': Icons.check_circle,
      };
    case 'TimGiaSu':
      return {
        'color': Colors.orange.shade700,
        'bgColor': Colors.orange.shade50,
        'icon': Icons.search,
      };
    case 'ChoDuyet':
      return {
        'color': Colors.blue.shade700,
        'bgColor': Colors.blue.shade50,
        'icon': Icons.pending,
      };
    default:
      return {
        'color': Colors.grey.shade700,
        'bgColor': Colors.grey.shade100,
        'icon': Icons.info_outline,
      };
  }
}
