import 'package:bloc/bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lich_hoc_repository.dart';

class LichHocBloc extends Bloc<LichHocEvent, LichHocState> {
  final LichHocRepository _lichHocRepository;

  LichHocBloc(this._lichHocRepository) : super(LichHocInitial()) {
    on<LoadLichHocEvent>(_onLoadLichHoc);
    on<TaoLichHocEvent>(_onTaoLichHoc);
    on<TaoLichHocLapLaiEvent>(_onTaoLichHocLapLai);
    on<CapNhatLichHocEvent>(_onCapNhatLichHoc);
    on<XoaLichHocEvent>(_onXoaLichHoc);
    on<ResetLichHocStateEvent>(_onResetState);
    on<LoadLichHocCuaGiaSuEvent>(_onLoadLichHocCuaGiaSu);
  }

  Future<void> _onLoadLichHoc(
    LoadLichHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final lichHocResponse = await _lichHocRepository.getLichHocTheoLop(
        event.lopYeuCauId,
      );
      emit(LichHocLoaded(lichHocResponse));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  // Future<void> _onTaoLichHoc(
  //   TaoLichHocEvent event,
  //   Emitter<LichHocState> emit,
  // ) async {
  //   try {
  //     final lichHoc = await _lichHocRepository.taoLichHocDon(
  //       event.lopYeuCauId,
  //       event.request,
  //     );
  //     emit(TaoLichHocSuccess([lichHoc], 'Tạo lịch học thành công'));
  //   } catch (e) {
  //     emit(LichHocError(e.toString()));
  //   }
  // }
  Future<void> _onTaoLichHoc(
    TaoLichHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading()); // <-- THÊM DÒNG NÀY
    try {
      final lichHoc = await _lichHocRepository.taoLichHocDon(
        event.lopYeuCauId,
        event.request,
      );
      emit(TaoLichHocSuccess([lichHoc], 'Tạo lịch học thành công'));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  // Future<void> _onTaoLichHocLapLai(
  //   TaoLichHocLapLaiEvent event,
  //   Emitter<LichHocState> emit,
  // ) async {
  //   try {
  //     final lichHocList = await _lichHocRepository.taoLichHocLapLai(
  //       event.lopYeuCauId,
  //       event.request,
  //     );
  //     final message =
  //         event.request.lapLai
  //             ? "Đã tạo ${lichHocList.length} buổi học lặp lại thành công"
  //             : "Tạo lịch học thành công";
  //     emit(TaoLichHocSuccess(lichHocList, message));
  //   } catch (e) {
  //     emit(LichHocError(e.toString()));
  //   }
  // }
  Future<void> _onTaoLichHocLapLai(
    TaoLichHocLapLaiEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading()); // <-- THÊM DÒNG NÀY
    try {
      final lichHocList = await _lichHocRepository.taoLichHocLapLai(
        event.lopYeuCauId,
        event.request,
      );
      final message =
          event.request.lapLai
              ? "Đã tạo ${lichHocList.length} buổi học lặp lại thành công"
              : "Tạo lịch học thành công";
      emit(TaoLichHocSuccess(lichHocList, message));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  // Future<void> _onCapNhatLichHoc(
  //   CapNhatLichHocEvent event,
  //   Emitter<LichHocState> emit,
  // ) async {
  //   try {
  //     final lichHoc = await _lichHocRepository.capNhatLichHoc(
  //       event.lichHocId,
  //       event.data,
  //     );
  //     emit(CapNhatLichHocSuccess(lichHoc, 'Cập nhật lịch học thành công'));
  //   } catch (e) {
  //     emit(LichHocError(e.toString()));
  //   }
  // }
  Future<void> _onCapNhatLichHoc(
    CapNhatLichHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading()); // <-- THÊM DÒNG NÀY
    try {
      final lichHoc = await _lichHocRepository.capNhatLichHoc(
        event.lichHocId,
        event.data,
      );
      emit(CapNhatLichHocSuccess(lichHoc, 'Cập nhật lịch học thành công'));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  // Future<void> _onXoaLichHoc(
  //   XoaLichHocEvent event,
  //   Emitter<LichHocState> emit,
  // ) async {
  //   try {
  //     await _lichHocRepository.xoaLichHoc(
  //       event.lichHocId,
  //       xoaCaChuoi: event.xoaCaChuoi,
  //     );
  //     final message =
  //         event.xoaCaChuoi
  //             ? 'Đã xóa cả chuỗi lịch học thành công'
  //             : 'Đã xóa buổi học thành công';
  //     emit(XoaLichHocSuccess(message));
  //   } catch (e) {
  //     emit(LichHocError(e.toString()));
  //   }
  // }
  Future<void> _onXoaLichHoc(
    XoaLichHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading()); // <-- THÊM DÒNG NÀY
    try {
      await _lichHocRepository.xoaLichHoc(
        event.lichHocId,
        xoaCaChuoi: event.xoaCaChuoi,
      );
      final message =
          event.xoaCaChuoi
              ? 'Đã xóa cả chuỗi lịch học thành công'
              : 'Đã xóa buổi học thành công';
      emit(XoaLichHocSuccess(message));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  void _onResetState(ResetLichHocStateEvent event, Emitter<LichHocState> emit) {
    emit(LichHocInitial());
  }

  // THÊM MỚI: Xử lý sự kiện load lịch học của gia sư
  Future<void> _onLoadLichHocCuaGiaSu(
    LoadLichHocCuaGiaSuEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final danhSachLichHoc = await _lichHocRepository.getLichHocTheoGiaSu();
      emit(LichHocCuaGiaSuLoaded(danhSachLichHoc));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }
}
