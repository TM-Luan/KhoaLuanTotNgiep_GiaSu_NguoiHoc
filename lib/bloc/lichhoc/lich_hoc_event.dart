part of 'lich_hoc_bloc.dart';

abstract class LichHocEvent {}

class LoadLichHocCalendar extends LichHocEvent {
  final int thang;
  final int nam;
  final DateTime ngayChon;
  final bool isGiaSu;
  LoadLichHocCalendar({
    required this.thang,
    required this.nam,
    required this.ngayChon,
    required this.isGiaSu,
  });
}

class ChangeLichHocNgay extends LichHocEvent {
  final DateTime ngayChon;
  final bool isGiaSu;
  ChangeLichHocNgay({required this.ngayChon, required this.isGiaSu});
}

class GetLichHocTheoLopVaThang extends LichHocEvent {
  final int lopYeuCauId;
  final int? thang;
  final int? nam;
  GetLichHocTheoLopVaThang({required this.lopYeuCauId, this.thang, this.nam});
}

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

class UpdateLichHoc extends LichHocEvent {
  final int lichHocId;
  final String? duongDan;
  final String? trangThai;
  UpdateLichHoc({required this.lichHocId, this.duongDan, this.trangThai});
}

class DeleteLichHoc extends LichHocEvent {
  final int lichHocId;
  final bool xoaCaChuoi;
  DeleteLichHoc({required this.lichHocId, this.xoaCaChuoi = false});
}

class DeleteAllLichHocLop extends LichHocEvent {
  final int lopYeuCauId;
  DeleteAllLichHocLop({required this.lopYeuCauId});
}

class CreateLichHocTheoTuan extends LichHocEvent {
  final int lopYeuCauId;
  final DateTime ngayBatDau;
  final int soTuan;
  final String? duongDan;
  final List<Map<String, dynamic>> buoiHocMau;

  CreateLichHocTheoTuan({
    required this.lopYeuCauId,
    required this.ngayBatDau,
    required this.soTuan,
    required this.buoiHocMau,
    this.duongDan,
  });
}
