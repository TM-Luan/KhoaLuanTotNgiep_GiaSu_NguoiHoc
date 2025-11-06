part of 'lich_hoc_bloc.dart';

abstract class LichHocEvent {}

// [MỚI] Event khi tải cả tháng (summary) VÀ chi tiết cho 1 ngày
class LoadLichHocCalendar extends LichHocEvent {
  final int thang;
  final int nam;
  final DateTime ngayChon;
  final bool isGiaSu; // Để BLoC biết gọi repo nào

  LoadLichHocCalendar({
    required this.thang,
    required this.nam,
    required this.ngayChon,
    required this.isGiaSu,
  });
}

// [MỚI] Event khi chỉ đổi ngày (lấy chi tiết, giữ summary cũ)
class ChangeLichHocNgay extends LichHocEvent {
  final DateTime ngayChon;
  final bool isGiaSu;

  ChangeLichHocNgay({required this.ngayChon, required this.isGiaSu});
}

// Lấy lịch học theo lớp và tháng
class GetLichHocTheoLopVaThang extends LichHocEvent {
  final int lopYeuCauId;
  final int? thang;
  final int? nam;

  GetLichHocTheoLopVaThang({required this.lopYeuCauId, this.thang, this.nam});
}

// Tạo lịch học
class CreateLichHoc extends LichHocEvent {
  final int lopYeuCauId;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  final String ngayHoc;
  final bool lapLai;
  final int soTuanLap;
  final String? duongDan;
  final String trangThai;

  CreateLichHoc({
    required this.lopYeuCauId,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.ngayHoc,
    required this.lapLai,
    this.soTuanLap = 1,
    this.duongDan,
    this.trangThai = 'SapToi',
  });
}

// Cập nhật lịch học
class UpdateLichHoc extends LichHocEvent {
  final int lichHocId;
  final String? thoiGianBatDau;
  final String? thoiGianKetThuc;
  final String? ngayHoc;
  final String? duongDan;
  final String? trangThai;

  UpdateLichHoc({
    required this.lichHocId,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.ngayHoc,
    this.duongDan,
    this.trangThai,
  });
}

// Xóa lịch học
class DeleteLichHoc extends LichHocEvent {
  final int lichHocId;
  final bool xoaCaChuoi;

  DeleteLichHoc({required this.lichHocId, this.xoaCaChuoi = false});
}
