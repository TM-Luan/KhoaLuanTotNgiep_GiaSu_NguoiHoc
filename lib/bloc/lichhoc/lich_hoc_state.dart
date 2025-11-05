part of 'lich_hoc_bloc.dart';
abstract class LichHocState {}

class LichHocInitial extends LichHocState {}

class LichHocLoading extends LichHocState {}

class LichHocTheoThangLoaded extends LichHocState {
  final LichHocTheoThangResponse response;

  LichHocTheoThangLoaded(this.response);
}

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
