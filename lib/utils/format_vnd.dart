import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final numberFormat = NumberFormat.decimalPattern('en_US');

String formatNumber(double? value) {
  if (value == null) return 'Chưa có';
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

  return phi.roundToDouble(); // trả về số chẵn gần nhất
}

double? toNumber(String? input) {
  if (input == null || input.isEmpty) return null;

  final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
  if (cleaned.isEmpty) return null;

  return double.tryParse(cleaned);
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
