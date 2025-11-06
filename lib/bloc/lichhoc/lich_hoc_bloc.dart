import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lich_hoc_repository.dart';
import '../../api/api_response.dart';

part 'lich_hoc_event.dart';
part 'lich_hoc_state.dart';

class LichHocBloc extends Bloc<LichHocEvent, LichHocState> {
  final LichHocRepository lichHocRepository;
  LichHocBloc(this.lichHocRepository) : super(LichHocInitial()) {
    // Handler mới cho Lịch chung
    on<LoadLichHocCalendar>(_onLoadLichHocCalendar);
    on<ChangeLichHocNgay>(_onChangeLichHocNgay);

    // Handler cũ (đã sửa) cho Lịch theo lớp
    on<GetLichHocTheoLopVaThang>(_onGetLichHocTheoLopVaThang);

    // Handler cho các hành động khác
    on<CreateLichHoc>(_onCreateLichHoc);
    on<UpdateLichHoc>(_onUpdateLichHoc);
    on<DeleteLichHoc>(_onDeleteLichHoc);
  }

  // [MỚI] Handler khi tải cả tháng (summary + 1 ngày chi tiết)
  Future<void> _onLoadLichHocCalendar(
    LoadLichHocCalendar event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());
    try {
      // Gọi 2 API song song
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

      // Chờ cả 2 hoàn thành
      final List<ApiResponse> responses = await Future.wait([
        summaryFuture,
        detailFuture,
      ]);

      final summaryResponse = responses[0] as ApiResponse<Set<String>>;
      final detailResponse = responses[1] as ApiResponse<List<LichHoc>>;

      if (summaryResponse.isSuccess && detailResponse.isSuccess) {
        emit(
          LichHocCalendarLoaded(
            ngayCoLich: summaryResponse.data ?? {},
            lichHocNgayChon: detailResponse.data ?? [],
            thangHienTai: DateTime(event.nam, event.thang),
            ngayChon: event.ngayChon,
          ),
        );
      } else {
        // Xử lý lỗi
        final errorMessage =
            !summaryResponse.isSuccess
                ? summaryResponse.message
                : detailResponse.message;
        emit(LichHocError(errorMessage));
      }
    } catch (e) {
      emit(LichHocError('Lỗi tải lịch học: ${e.toString()}'));
    }
  }

  // [MỚI] Handler khi chỉ thay đổi ngày
  Future<void> _onChangeLichHocNgay(
    ChangeLichHocNgay event,
    Emitter<LichHocState> emit,
  ) async {
    final currentState = state;
    if (currentState is LichHocCalendarLoaded) {
      // Giữ nguyên summary cũ, chỉ tải lại detail
      emit(
        currentState.copyWith(
          isLoadingDetails: true, // Hiển thị loading cho danh sách
          ngayChon: event.ngayChon,
        ),
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
          emit(
            currentState.copyWith(
              lichHocNgayChon: detailResponse.data ?? [],
              ngayChon: event.ngayChon,
              isLoadingDetails: false,
            ),
          );
        } else {
          emit(LichHocError(detailResponse.message));
          // Rollback về state cũ nếu lỗi
          emit(currentState.copyWith(isLoadingDetails: false));
        }
      } catch (e) {
        emit(LichHocError('Lỗi tải lịch học: ${e.toString()}'));
        emit(currentState.copyWith(isLoadingDetails: false));
      }
    }
  }

  // [SỬA] Handler này bây giờ sẽ emit State mới
  Future<void> _onGetLichHocTheoLopVaThang(
    GetLichHocTheoLopVaThang event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());

    final ApiResponse<LichHocTheoThangResponse> response =
        await lichHocRepository.getLichHocTheoLopVaThang(
          lopYeuCauId: event.lopYeuCauId,
          thang: event.thang,
          nam: event.nam,
        );

    if (response.isSuccess && response.data != null) {
      // SỬA DÒNG NÀY:
      emit(
        LichHocLopLoaded(response.data!),
      ); // <-- Dùng state 'LichHocLopLoaded' mới
    } else {
      emit(LichHocError(response.message));
    }
  }

  // === Các handler khác giữ nguyên ===

  Future<void> _onCreateLichHoc(
    CreateLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());

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
  }

  Future<void> _onUpdateLichHoc(
    UpdateLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());

    final ApiResponse<LichHoc> response = await lichHocRepository
        .capNhatLichHoc(
          lichHocId: event.lichHocId,
          thoiGianBatDau: event.thoiGianBatDau,
          thoiGianKetThuc: event.thoiGianKetThuc,
          ngayHoc: event.ngayHoc,
          duongDan: event.duongDan,
          trangThai: event.trangThai,
        );

    if (response.isSuccess && response.data != null) {
      emit(LichHocUpdated(response.data!));
    } else {
      emit(LichHocError(response.message));
    }
  }

  Future<void> _onDeleteLichHoc(
    DeleteLichHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());

    final ApiResponse<dynamic> response = await lichHocRepository.xoaLichHoc(
      lichHocId: event.lichHocId,
      xoaCaChuoi: event.xoaCaChuoi,
    );

    if (response.isSuccess) {
      emit(LichHocDeleted(response.message));
    } else {
      emit(LichHocError(response.message));
    }
  }
}
