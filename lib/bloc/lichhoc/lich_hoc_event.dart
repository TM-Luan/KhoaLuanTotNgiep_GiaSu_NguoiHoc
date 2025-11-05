part of 'lich_hoc_bloc.dart';
abstract class LichHocEvent {}

// Lấy lịch học theo tháng cho gia sư
class GetLichHocTheoThangGiaSu extends LichHocEvent {
  final int? thang;
  final int? nam;
  final int? lopYeuCauId;

  GetLichHocTheoThangGiaSu({this.thang, this.nam, this.lopYeuCauId});
}

// Lấy lịch học theo tháng cho người học
class GetLichHocTheoThangNguoiHoc extends LichHocEvent {
  final int? thang;
  final int? nam;
  final int? lopYeuCauId;

  GetLichHocTheoThangNguoiHoc({this.thang, this.nam, this.lopYeuCauId});
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
