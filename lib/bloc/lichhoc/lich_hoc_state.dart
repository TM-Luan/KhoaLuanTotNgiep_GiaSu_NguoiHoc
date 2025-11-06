part of 'lich_hoc_bloc.dart';

abstract class LichHocState {}

class LichHocInitial extends LichHocState {}

class LichHocLoading extends LichHocState {}

// State cho 2 màn hình Lịch chính (Gia Sư, Học Sinh)
class LichHocCalendarLoaded extends LichHocState {
  final Set<String> ngayCoLich; // Dùng Set để tra cứu O(1)
  final List<LichHoc> lichHocNgayChon;
  final DateTime thangHienTai;
  final DateTime ngayChon;
  final bool isLoadingDetails; // Cờ loading khi chỉ đổi ngày

  LichHocCalendarLoaded({
    required this.ngayCoLich,
    required this.lichHocNgayChon,
    required this.thangHienTai,
    required this.ngayChon,
    this.isLoadingDetails = false,
  });

  LichHocCalendarLoaded copyWith({
    Set<String>? ngayCoLich,
    List<LichHoc>? lichHocNgayChon,
    DateTime? thangHienTai,
    DateTime? ngayChon,
    bool? isLoadingDetails,
  }) {
    return LichHocCalendarLoaded(
      ngayCoLich: ngayCoLich ?? this.ngayCoLich,
      lichHocNgayChon: lichHocNgayChon ?? this.lichHocNgayChon,
      thangHienTai: thangHienTai ?? this.thangHienTai,
      ngayChon: ngayChon ?? this.ngayChon,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
    );
  }
}

// [THÊM MỚI] State riêng cho màn hình "Lịch học theo lớp"
class LichHocLopLoaded extends LichHocState {
  final LichHocTheoThangResponse response;
  LichHocLopLoaded(this.response);
}

// === Các state khác giữ nguyên ===

class LichHocCreated extends LichHocState {
  final List<LichHoc> danhSachLichHoc;
  LichHocCreated(this.danhSachLichHoc);
}

class LichHocUpdated extends LichHocState {
  final LichHoc lichHoc;
  LichHocUpdated(this.lichHoc);
}

class LichHocDeleted extends LichHocState {
  final String message;
  LichHocDeleted(this.message);
}

class LichHocError extends LichHocState {
  final String message;
  LichHocError(this.message);
}
