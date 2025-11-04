import 'package:equatable/equatable.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

abstract class LichHocState extends Equatable {
  const LichHocState();

  @override
  List<Object> get props => [];
}

class LichHocInitial extends LichHocState {}

class LichHocLoading extends LichHocState {}

class LichHocLoaded extends LichHocState {
  final LichHocResponse lichHocResponse;
  List<LichHoc> get allLichHoc => lichHocResponse.lichHoc;

  const LichHocLoaded(this.lichHocResponse);

  @override
  List<Object> get props => [lichHocResponse];
}
class LichHocCuaGiaSuLoaded extends LichHocState {
  final List<LichHoc> danhSachLichHoc;

  const LichHocCuaGiaSuLoaded(this.danhSachLichHoc);

  @override
  List<Object> get props => [danhSachLichHoc];
}
class LichHocError extends LichHocState {
  final String message;

  const LichHocError(this.message);

  @override
  List<Object> get props => [message];
}

class TaoLichHocSuccess extends LichHocState {
  final List<LichHoc> lichHocTaoMoi;
  final String message;

  const TaoLichHocSuccess(this.lichHocTaoMoi, this.message);

  @override
  List<Object> get props => [lichHocTaoMoi, message];
}

class CapNhatLichHocSuccess extends LichHocState {
  final LichHoc lichHoc;
  final String message;

  const CapNhatLichHocSuccess(this.lichHoc, this.message);

  @override
  List<Object> get props => [lichHoc, message];
}

class XoaLichHocSuccess extends LichHocState {
  final String message;

  const XoaLichHocSuccess(this.message);

  @override
  List<Object> get props => [message];
}
