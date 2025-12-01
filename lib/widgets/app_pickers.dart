import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class AppPickers {
  // Hàm dùng chung để hiển thị BottomSheet chứa Picker
  static Future<T?> _showWheelPicker<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    required VoidCallback onConfirm,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            height: 300, // Chiều cao vừa đủ cho wheel
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                // --- Header: Handle bar + Title + Button ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút Hủy (ẩn hoặc hiện tùy ý, ở đây để trống để cân bằng)
                      const SizedBox(width: 60),

                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      // Nút Xong
                      GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Xong",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // --- Phần nội dung Picker (Wheel) ---
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 22,
                          color: Colors.black87,
                          fontWeight:
                              FontWeight.w500, // Font chữ vừa phải, clean
                        ),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 1. CHỌN GIỜ (Giống hệt hình ảnh bạn gửi)
  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    final init = initialTime ?? TimeOfDay.now();
    // Convert TimeOfDay sang DateTime để dùng CupertinoDatePicker
    final now = DateTime.now();
    DateTime tempDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      init.hour,
      init.minute,
    );

    final result = await _showWheelPicker<DateTime>(
      context,
      title: "Chọn giờ",
      onConfirm: () => Navigator.pop(context, tempDateTime),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time, // Chế độ chỉ hiện giờ/phút/AM-PM
        initialDateTime: tempDateTime,
        use24hFormat: false, // Để hiện AM/PM giống hình
        onDateTimeChanged: (newDate) => tempDateTime = newDate,
      ),
    );

    if (result != null) {
      return TimeOfDay.fromDateTime(result);
    }
    return null;
  }

  /// 2. CHỌN NGÀY (Cũng kiểu Wheel cho đồng bộ)
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final min = firstDate ?? DateTime(1900);
    final max = lastDate ?? DateTime(2100);

    // Clamp initialDate to be within [min, max]
    DateTime init = initialDate ?? DateTime.now();
    if (init.isBefore(min)) {
      init = min;
    } else if (init.isAfter(max)) {
      init = max;
    }

    DateTime tempDate = init;

    return await _showWheelPicker<DateTime>(
      context,
      title: "Chọn ngày",
      onConfirm: () => Navigator.pop(context, tempDate),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date, // Chế độ ngày tháng năm
        initialDateTime: init,
        minimumDate: min,
        maximumDate: max,
        dateOrder:
            DatePickerDateOrder.dmy, // Định dạng Ngày - Tháng - Năm (Việt Nam)
        onDateTimeChanged: (newDate) => tempDate = newDate,
      ),
    );
  }
}
