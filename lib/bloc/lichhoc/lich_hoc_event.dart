// bloc/lich_hoc/lich_hoc_event.dart
import 'package:equatable/equatable.dart';

abstract class LichHocEvent extends Equatable {
  const LichHocEvent();

  @override
  List<Object?> get props => [];
}

// Lấy lịch học theo lớp
class LoadLichHocTheoLopEvent extends LichHocEvent {
  final int lopYeuCauId;

  const LoadLichHocTheoLopEvent(this.lopYeuCauId);

  @override
  List<Object?> get props => [lopYeuCauId];
}

// Lấy lịch học của gia sư - EVENT CHÍNH CẦN DÙNG
class LoadLichHocCuaGiaSuEvent extends LichHocEvent {
  const LoadLichHocCuaGiaSuEvent();
}

// Lấy lịch học của người học
class LoadLichHocCuaNguoiHocEvent extends LichHocEvent {
  const LoadLichHocCuaNguoiHocEvent();
}

// Lấy lịch học theo khoảng thời gian
class LoadLichHocTheoThoiGianEvent extends LichHocEvent {
  final String tuNgay;
  final String denNgay;
  final bool isGiaSu;

  const LoadLichHocTheoThoiGianEvent({
    required this.tuNgay,
    required this.denNgay,
    required this.isGiaSu,
  });

  @override
  List<Object?> get props => [tuNgay, denNgay, isGiaSu];
}

// Tạo lịch học mới
class TaoLichHocEvent extends LichHocEvent {
  final int lopYeuCauId;
  final Map<String, dynamic> lichHocData;

  const TaoLichHocEvent({
    required this.lopYeuCauId,
    required this.lichHocData,
  });

  @override
  List<Object?> get props => [lopYeuCauId, lichHocData];
}

// Cập nhật lịch học
class CapNhatLichHocEvent extends LichHocEvent {
  final int lichHocId;
  final Map<String, dynamic> updateData;

  const CapNhatLichHocEvent({
    required this.lichHocId,
    required this.updateData,
  });

  @override
  List<Object?> get props => [lichHocId, updateData];
}

// Cập nhật trạng thái lịch học
class CapNhatTrangThaiLichHocEvent extends LichHocEvent {
  final int lichHocId;
  final String trangThai;
  final String? duongDan;

  const CapNhatTrangThaiLichHocEvent({
    required this.lichHocId,
    required this.trangThai,
    this.duongDan,
  });

  @override
  List<Object?> get props => [lichHocId, trangThai, duongDan];
}