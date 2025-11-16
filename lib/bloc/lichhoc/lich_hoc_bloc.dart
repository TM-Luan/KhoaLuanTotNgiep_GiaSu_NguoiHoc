// file: lich_hoc_bloc.dart (SỬA LỖI KẸT STATE)

import 'package:bloc/bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lich_hoc_repository.dart';
import '../../api/api_response.dart';

part 'lich_hoc_event.dart';
part 'lich_hoc_state.dart';

class LichHocBloc extends Bloc<LichHocEvent, LichHocState> {
  final LichHocRepository lichHocRepository;

  // [SỬA 1] Thêm biến cache để lưu state Loaded cuối cùng
  LichHocCalendarLoaded? _lastLoadedState;

  LichHocBloc(this.lichHocRepository) : super(LichHocInitial()) {
    on<LoadLichHocCalendar>(_onLoadLichHocCalendar);
    on<ChangeLichHocNgay>(_onChangeLichHocNgay);
    on<GetLichHocTheoLopVaThang>(_onGetLichHocTheoLopVaThang);
    on<CreateLichHoc>(_onCreateLichHoc);
    on<UpdateLichHoc>(_onUpdateLichHoc);
    on<DeleteLichHoc>(_onDeleteLichHoc);
    on<DeleteAllLichHocLop>(_onDeleteAllLichHocLop);
    on<CreateLichHocTheoTuan>(_onCreateLichHocTheoTuan);
  }

  Future<void> _onLoadLichHocCalendar(
    LoadLichHocCalendar event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final summaryFuture =
          event.isGiaSu
              ? lichHocRepository.getLichHocSummaryGiaSu(
                thang: event.thang,
                nam: event.nam,
              )
              : lichHocRepository.getLichHocSummaryNguoiHoc(
                thang: event.thang,
                nam: event.nam,
              );

      final detailFuture =
          event.isGiaSu
              ? lichHocRepository.getLichHocTheoNgayGiaSu(ngay: event.ngayChon)
              : lichHocRepository.getLichHocTheoNgayNguoiHoc(
                ngay: event.ngayChon,
              );

      final List<ApiResponse> responses = await Future.wait([
        summaryFuture,
        detailFuture,
      ]);

      final summaryResponse = responses[0] as ApiResponse<Set<String>>;
      final detailResponse = responses[1] as ApiResponse<List<LichHoc>>;

      if (summaryResponse.isSuccess && detailResponse.isSuccess) {
        // [SỬA 2] Lưu state mới vào cache
        final newState = LichHocCalendarLoaded(
          ngayCoLich: summaryResponse.data ?? {},
          lichHocNgayChon: detailResponse.data ?? [],
          thangHienTai: DateTime(event.nam, event.thang),
          ngayChon: event.ngayChon,
        );
        emit(newState);
        _lastLoadedState = newState; // Cập nhật cache
      } else {
        final errorMessage =
            !summaryResponse.isSuccess
                ? summaryResponse.message
                : detailResponse.message;
        emit(LichHocError(errorMessage));
      }
    } catch (e) {
      emit(LichHocError('Lỗi tải lịch học (calendar): ${e.toString()}'));
    }
  }

  Future<void> _onChangeLichHocNgay(
    ChangeLichHocNgay event,
    Emitter<LichHocState> emit,
  ) async {
    // [SỬA 3] Lấy state từ cache, thay vì state hiện tại (có thể đang là Updated)
    final currentState = _lastLoadedState;

    if (currentState != null) {
      // Emit state loading (chỉ loading phần list)
      final loadingState = currentState.copyWith(
        isLoadingDetails: true,
        ngayChon: event.ngayChon,
      );
      emit(loadingState);
      _lastLoadedState = loadingState; // Cập nhật cache

      try {
        final detailResponse =
            event.isGiaSu
                ? await lichHocRepository.getLichHocTheoNgayGiaSu(
                  ngay: event.ngayChon,
                )
                : await lichHocRepository.getLichHocTheoNgayNguoiHoc(
                  ngay: event.ngayChon,
                );

        if (detailResponse.isSuccess) {
          // [SỬA 4] Cập nhật cache với data mới
          final newState = currentState.copyWith(
            lichHocNgayChon: detailResponse.data ?? [],
            ngayChon: event.ngayChon,
            isLoadingDetails: false,
          );
          emit(newState);
          _lastLoadedState = newState; // Cập nhật cache
        } else {
          // Khi lỗi, trả về state lỗi VÀ tắt loading
          final errorState = currentState.copyWith(isLoadingDetails: false);
          emit(errorState);
          _lastLoadedState = errorState; // Cập nhật cache
          emit(LichHocError(detailResponse.message));
        }
      } catch (e) {
        // Khi crash, trả về state lỗi VÀ tắt loading
        final errorState = currentState.copyWith(isLoadingDetails: false);
        emit(errorState);
        _lastLoadedState = errorState; // Cập nhật cache
        emit(LichHocError('Lỗi tải chi tiết ngày: ${e.toString()}'));
      }
    } else {
      // Trường hợp hiếm gặp: _lastLoadedState bị null
      emit(LichHocError('Trạng thái lịch học bị mất. Vui lòng tải lại.'));
    }
  }

  // --- Các hàm Create, Update, Delete đã có try/catch (Giữ nguyên) ---

  Future<void> _onGetLichHocTheoLopVaThang(
    GetLichHocTheoLopVaThang event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final ApiResponse<LichHocTheoThangResponse> response =
          await lichHocRepository.getLichHocTheoLopVaThang(
            lopYeuCauId: event.lopYeuCauId,
            thang: event.thang,
            nam: event.nam,
          );

      if (response.isSuccess && response.data != null) {
        emit(LichHocLopLoaded(response.data!));
      } else {
        emit(LichHocError(response.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi tải lịch học theo lớp: ${e.toString()}'));
    }
  }

  Future<void> _onCreateLichHoc(
    CreateLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final ApiResponse<List<LichHoc>> response = await lichHocRepository
          .taoLichHocLapLai(
            lopYeuCauId: event.lopYeuCauId,
            thoiGianBatDau: event.thoiGianBatDau,
            thoiGianKetThuc: event.thoiGianKetThuc,
            ngayHoc: event.ngayHoc,
            lapLai: event.lapLai,
            soTuanLap: event.soTuanLap,
            duongDan: event.duongDan,
            trangThai: event.trangThai,
          );

      if (response.isSuccess && response.data != null) {
        emit(LichHocCreated(response.data!));
      } else {
        emit(LichHocError(response.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi tạo lịch học: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateLichHoc(
    UpdateLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    // Không emit Loading
    try {
      final ApiResponse<LichHoc> response = await lichHocRepository
          .capNhatLichHoc(
            lichHocId: event.lichHocId,
            duongDan: event.duongDan,
            trangThai: event.trangThai,
          );

      if (response.isSuccess && response.data != null) {
        // [SỬA 5] Chỉ emit Updated.
        // BLoC sẽ không bị kẹt state nữa vì _onChangeLichHocNgay (do listener gọi)
        // sẽ dùng _lastLoadedState.
        emit(LichHocUpdated(response.data!));
      } else {
        emit(LichHocError(response.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi cập nhật lịch học: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteLichHoc(
    DeleteLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final ApiResponse<dynamic> response = await lichHocRepository.xoaLichHoc(
        lichHocId: event.lichHocId,
        xoaCaChuoi: event.xoaCaChuoi,
      );

      if (response.isSuccess) {
        emit(LichHocDeleted(response.message));
      } else {
        emit(LichHocError(response.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi xóa lịch học: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAllLichHocLop(
    DeleteAllLichHocLop event,
    Emitter<LichHocState> emit,
  ) async {
    // Tạm thời emit Loading chung
    emit(LichHocLoading());
    try {
      final ApiResponse<dynamic> response = await lichHocRepository
          .xoaTatCaLichHocTheoLop(lopYeuCauId: event.lopYeuCauId);

      if (response.isSuccess) {
        // Dùng lại state Deleted chung
        emit(LichHocDeleted(response.message));
      } else {
        emit(LichHocError(response.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi xóa toàn bộ lịch học: ${e.toString()}'));
    }
  }

  Future<void> _onCreateLichHocTheoTuan(
    CreateLichHocTheoTuan event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final ApiResponse<List<LichHoc>> response = await lichHocRepository
          .taoLichHocTheoTuan(
            lopYeuCauId: event.lopYeuCauId,
            ngayBatDau: event.ngayBatDau,
            soTuan: event.soTuan,
            buoiHocMau: event.buoiHocMau, // [SỬA]
            duongDan: event.duongDan,
          );

      if (response.isSuccess && response.data != null) {
        emit(LichHocCreated(response.data!));
      } else {
        emit(LichHocError(response.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi tạo lịch học theo tuần: ${e.toString()}'));
    }
  }
}
