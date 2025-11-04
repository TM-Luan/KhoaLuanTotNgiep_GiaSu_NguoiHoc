import 'package:equatable/equatable.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

abstract class LichHocEvent extends Equatable {
  const LichHocEvent();

  @override
  List<Object> get props => [];
}

class LoadLichHocEvent extends LichHocEvent {
  final int lopYeuCauId;

  const LoadLichHocEvent(this.lopYeuCauId);

  @override
  List<Object> get props => [lopYeuCauId];
}
class LoadLichHocCuaGiaSuEvent extends LichHocEvent {
  const LoadLichHocCuaGiaSuEvent();

  @override
  List<Object> get props => [];
}
class TaoLichHocEvent extends LichHocEvent {
  final int lopYeuCauId;
  final TaoLichHocRequest request;

  const TaoLichHocEvent(this.lopYeuCauId, this.request);

  @override
  List<Object> get props => [lopYeuCauId, request];
}

class TaoLichHocLapLaiEvent extends LichHocEvent {
  final int lopYeuCauId;
  final TaoLichHocRequest request;

  const TaoLichHocLapLaiEvent(this.lopYeuCauId, this.request);

  @override
  List<Object> get props => [lopYeuCauId, request];
}

class CapNhatLichHocEvent extends LichHocEvent {
  final int lichHocId;
  final Map<String, dynamic> data;

  const CapNhatLichHocEvent(this.lichHocId, this.data);

  @override
  List<Object> get props => [lichHocId, data];
}

class XoaLichHocEvent extends LichHocEvent {
  final int lichHocId;
  final bool xoaCaChuoi;

  const XoaLichHocEvent(this.lichHocId, {this.xoaCaChuoi = false});

  @override
  List<Object> get props => [lichHocId, xoaCaChuoi];
}

class ResetLichHocStateEvent extends LichHocEvent {}
