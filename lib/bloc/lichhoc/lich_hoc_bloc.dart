import 'package:bloc/bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lich_hoc_repository.dart';
import '../../api/api_response.dart';

part 'lich_hoc_event.dart';
part 'lich_hoc_state.dart';

class LichHocBloc extends Bloc<LichHocEvent, LichHocState> {
  final LichHocRepository lichHocRepository;

  // Cache state để giữ UI lịch khi đổi ngày
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
      // Gọi song song cả API summary (dấu chấm) và chi tiết ngày
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
        final newState = LichHocCalendarLoaded(
          ngayCoLich: summaryResponse.data ?? {},
          lichHocNgayChon: detailResponse.data ?? [],
          thangHienTai: DateTime(event.nam, event.thang),
          ngayChon: event.ngayChon,
        );
        emit(newState);
        _lastLoadedState = newState; // Lưu cache
      } else {
        emit(LichHocError(summaryResponse.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi tải lịch học: ${e.toString()}'));
    }
  }

  Future<void> _onChangeLichHocNgay(
    ChangeLichHocNgay event,
    Emitter<LichHocState> emit,
  ) async {
    // Dùng lại state cũ để không mất giao diện lịch
    final currentState = _lastLoadedState;

    if (currentState != null) {
      emit(
        currentState.copyWith(isLoadingDetails: true, ngayChon: event.ngayChon),
      );

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
          final newState = currentState.copyWith(
            lichHocNgayChon: detailResponse.data ?? [],
            ngayChon: event.ngayChon,
            isLoadingDetails: false,
          );
          emit(newState);
          _lastLoadedState = newState; // Update cache
        } else {
          emit(currentState.copyWith(isLoadingDetails: false));
          emit(LichHocError(detailResponse.message));
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingDetails: false));
        emit(LichHocError('Lỗi tải chi tiết ngày: ${e.toString()}'));
      }
    } else {
      // Nếu mất state gốc, buộc phải load lại từ đầu (ít xảy ra)
      add(
        LoadLichHocCalendar(
          thang: event.ngayChon.month,
          nam: event.ngayChon.year,
          ngayChon: event.ngayChon,
          isGiaSu: event.isGiaSu,
        ),
      );
    }
  }

  Future<void> _onUpdateLichHoc(
    UpdateLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    try {
      final ApiResponse<LichHoc> response = await lichHocRepository
          .capNhatLichHoc(
            lichHocId: event.lichHocId,
            duongDan: event.duongDan,
            trangThai: event.trangThai,
          );

      if (response.isSuccess && response.data != null) {
        emit(LichHocUpdated(response.data!));
      } else {
        emit(LichHocError(response.message));
      }
    } catch (e) {
      emit(LichHocError('Lỗi cập nhật: ${e.toString()}'));
    }
  }

  // --- Các hàm khác giữ nguyên logic ---
  Future<void> _onGetLichHocTheoLopVaThang(
    GetLichHocTheoLopVaThang event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final response = await lichHocRepository.getLichHocTheoLopVaThang(
        lopYeuCauId: event.lopYeuCauId,
        thang: event.thang,
        nam: event.nam,
      );
      if (response.isSuccess)
        emit(LichHocLopLoaded(response.data!));
      else
        emit(LichHocError(response.message));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  Future<void> _onCreateLichHoc(
    CreateLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final response = await lichHocRepository.taoLichHocLapLai(
        lopYeuCauId: event.lopYeuCauId,
        thoiGianBatDau: event.thoiGianBatDau,
        thoiGianKetThuc: event.thoiGianKetThuc,
        ngayHoc: event.ngayHoc,
        lapLai: event.lapLai,
        soTuanLap: event.soTuanLap,
        duongDan: event.duongDan,
        trangThai: event.trangThai,
      );
      if (response.isSuccess)
        emit(LichHocCreated(response.data!));
      else
        emit(LichHocError(response.message));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  Future<void> _onDeleteLichHoc(
    DeleteLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final response = await lichHocRepository.xoaLichHoc(
        lichHocId: event.lichHocId,
        xoaCaChuoi: event.xoaCaChuoi,
      );
      if (response.isSuccess)
        emit(LichHocDeleted(response.message));
      else
        emit(LichHocError(response.message));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  Future<void> _onDeleteAllLichHocLop(
    DeleteAllLichHocLop event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final response = await lichHocRepository.xoaTatCaLichHocTheoLop(
        lopYeuCauId: event.lopYeuCauId,
      );
      if (response.isSuccess)
        emit(LichHocDeleted(response.message));
      else
        emit(LichHocError(response.message));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }

  Future<void> _onCreateLichHocTheoTuan(
    CreateLichHocTheoTuan event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      final response = await lichHocRepository.taoLichHocTheoTuan(
        lopYeuCauId: event.lopYeuCauId,
        ngayBatDau: event.ngayBatDau,
        soTuan: event.soTuan,
        buoiHocMau: event.buoiHocMau,
        duongDan: event.duongDan,
      );
      if (response.isSuccess)
        emit(LichHocCreated(response.data!));
      else
        emit(LichHocError(response.message));
    } catch (e) {
      emit(LichHocError(e.toString()));
    }
  }
}
