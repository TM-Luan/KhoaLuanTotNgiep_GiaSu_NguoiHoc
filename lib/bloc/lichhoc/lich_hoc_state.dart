// bloc/lich_hoc/lich_hoc_state.dart
import 'package:equatable/equatable.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

abstract class LichHocState extends Equatable {
  const LichHocState();

  @override
  List<Object?> get props => [];
}

class LichHocInitialState extends LichHocState {
  const LichHocInitialState();
}

class LichHocLoadingState extends LichHocState {
  const LichHocLoadingState();
}

class LichHocLoadedState extends LichHocState {
  final List<LichHoc> danhSachLichHoc;
  final String? message;

  const LichHocLoadedState(this.danhSachLichHoc, {this.message});

  @override
  List<Object?> get props => [danhSachLichHoc, message];
}

class LichHocTheoLopLoadedState extends LichHocState {
  final List<LichHoc> danhSachLichHoc;
  final int lopYeuCauId;

  const LichHocTheoLopLoadedState(this.danhSachLichHoc, this.lopYeuCauId);

  @override
  List<Object?> get props => [danhSachLichHoc, lopYeuCauId];
}

class LichHocCreatedState extends LichHocState {
  final LichHoc lichHoc;
  final String message;

  const LichHocCreatedState(this.lichHoc, this.message);

  @override
  List<Object?> get props => [lichHoc, message];
}

class LichHocUpdatedState extends LichHocState {
  final LichHoc lichHoc;
  final String message;

  const LichHocUpdatedState(this.lichHoc, this.message);

  @override
  List<Object?> get props => [lichHoc, message];
}

class LichHocErrorState extends LichHocState {
  final String message;

  const LichHocErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
