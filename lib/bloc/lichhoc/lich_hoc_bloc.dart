// bloc/lich_hoc/lich_hoc_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lich_hoc_repository.dart';

class LichHocBloc extends Bloc<LichHocEvent, LichHocState> {
  final LichHocRepository _lichHocRepository;

  LichHocBloc(this._lichHocRepository) : super(const LichHocInitialState()) {
    // ĐĂNG KÝ TẤT CẢ EVENT HANDLERS
    on<LoadLichHocTheoLopEvent>(_onLoadLichHocTheoLop);
    on<LoadLichHocCuaGiaSuEvent>(_onLoadLichHocCuaGiaSu);
    on<LoadLichHocCuaNguoiHocEvent>(_onLoadLichHocCuaNguoiHoc);
    on<LoadLichHocTheoThoiGianEvent>(_onLoadLichHocTheoThoiGian);
    on<TaoLichHocEvent>(_onTaoLichHoc);
    on<CapNhatLichHocEvent>(_onCapNhatLichHoc);
    on<CapNhatTrangThaiLichHocEvent>(_onCapNhatTrangThaiLichHoc);
  }

  Future<void> _onLoadLichHocTheoLop(
    LoadLichHocTheoLopEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(const LichHocLoadingState());
    
    final response = await _lichHocRepository.getLichHocTheoLop(event.lopYeuCauId);
    
    if (response.success && response.data != null) {
      emit(LichHocTheoLopLoadedState(response.data!, event.lopYeuCauId));
    } else {
      emit(LichHocErrorState(response.message));
    }
  }

  Future<void> _onLoadLichHocCuaGiaSu(
    LoadLichHocCuaGiaSuEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(const LichHocLoadingState());
    
    final response = await _lichHocRepository.getLichHocCuaGiaSu();
    
    if (response.success && response.data != null) {
      emit(LichHocLoadedState(response.data!));
    } else {
      emit(LichHocErrorState(response.message));
    }
  }

  Future<void> _onLoadLichHocCuaNguoiHoc(
    LoadLichHocCuaNguoiHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(const LichHocLoadingState());
    
    final response = await _lichHocRepository.getLichHocCuaNguoiHoc();
    
    if (response.success && response.data != null) {
      emit(LichHocLoadedState(response.data!));
    } else {
      emit(LichHocErrorState(response.message));
    }
  }

  Future<void> _onLoadLichHocTheoThoiGian(
    LoadLichHocTheoThoiGianEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(const LichHocLoadingState());
    
    final response = await _lichHocRepository.getLichHocTheoThoiGian(
      tuNgay: event.tuNgay,
      denNgay: event.denNgay,
      isGiaSu: event.isGiaSu,
    );
    
    if (response.success && response.data != null) {
      emit(LichHocLoadedState(response.data!));
    } else {
      emit(LichHocErrorState(response.message));
    }
  }

  Future<void> _onTaoLichHoc(
    TaoLichHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(const LichHocLoadingState());
    
    final response = await _lichHocRepository.taoLichHocGiaSu(
      lopYeuCauId: event.lopYeuCauId,
      lichHocData: event.lichHocData,
    );
    
    if (response.success && response.data != null) {
      emit(LichHocCreatedState(response.data!, response.message));
      // Reload lịch học sau khi tạo
      add(const LoadLichHocCuaGiaSuEvent());
    } else {
      emit(LichHocErrorState(response.message));
    }
  }

  Future<void> _onCapNhatLichHoc(
    CapNhatLichHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    emit(const LichHocLoadingState());
    
    final response = await _lichHocRepository.capNhatLichHocGiaSu(
      lichHocId: event.lichHocId,
      updateData: event.updateData,
    );
    
    if (response.success && response.data != null) {
      emit(LichHocUpdatedState(response.data!, response.message));
      // Reload sau khi cập nhật
      add(const LoadLichHocCuaGiaSuEvent());
    } else {
      emit(LichHocErrorState(response.message));
    }
  }

  Future<void> _onCapNhatTrangThaiLichHoc(
    CapNhatTrangThaiLichHocEvent event,
    Emitter<LichHocState> emit,
  ) async {
    final updateData = {
      'TrangThai': event.trangThai,
      if (event.duongDan != null) 'DuongDan': event.duongDan,
    };
    
    add(CapNhatLichHocEvent(
      lichHocId: event.lichHocId,
      updateData: updateData,
    ));
  }
}