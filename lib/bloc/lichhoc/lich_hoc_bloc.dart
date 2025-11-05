import 'package:bloc/bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lich_hoc_repository.dart';
import '../../api/api_response.dart';

part 'lich_hoc_event.dart';
part 'lich_hoc_state.dart';

class LichHocBloc extends Bloc<LichHocEvent, LichHocState> {
  final LichHocRepository lichHocRepository;
  LichHocBloc(this.lichHocRepository) : super(LichHocInitial()) {
    on<GetLichHocTheoThangGiaSu>(_onGetLichHocTheoThangGiaSu);
    on<GetLichHocTheoThangNguoiHoc>(_onGetLichHocTheoThangNguoiHoc);
    on<GetLichHocTheoLopVaThang>(_onGetLichHocTheoLopVaThang);
    on<CreateLichHoc>(_onCreateLichHoc);
    on<UpdateLichHoc>(_onUpdateLichHoc);
    on<DeleteLichHoc>(_onDeleteLichHoc);
  }

  // Future<void> _onGetLichHocTheoThangGiaSu(
  //   GetLichHocTheoThangGiaSu event,
  //   Emitter<LichHocState> emit,
  // ) async {
  //   emit(LichHocLoading());

  //   final ApiResponse<LichHocTheoThangResponse> response =
  //       await lichHocRepository.getLichHocTheoThangGiaSu(
  //     thang: event.thang,
  //     nam: event.nam,
  //     lopYeuCauId: event.lopYeuCauId,
  //   );

  //   if (response.isSuccess && response.data != null) {
  //     emit(LichHocTheoThangLoaded(response.data!));
  //   } else {
  //     emit(LichHocError(response.message));
  //   }
  // }
  Future<void> _onGetLichHocTheoThangGiaSu(
    GetLichHocTheoThangGiaSu event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());

    try {
      print('🔄 Bloc: Bắt đầu gọi API lịch học theo tháng');
      print(
        '📅 Tham số: thang=${event.thang}, nam=${event.nam}, lopYeuCauId=${event.lopYeuCauId}',
      );

      final ApiResponse<LichHocTheoThangResponse> response =
          await lichHocRepository.getLichHocTheoThangGiaSu(
            thang: event.thang,
            nam: event.nam,
            lopYeuCauId: event.lopYeuCauId,
          );

      print('📦 Bloc: Nhận được response từ repository');
      print('📦 Response success: ${response.isSuccess}');
      print('📦 Response message: ${response.message}');
      print('📦 Response data: ${response.data != null ? "có data" : "null"}');

      if (response.isSuccess && response.data != null) {
        print('✅ Bloc: Phát state LichHocTheoThangLoaded');
        emit(LichHocTheoThangLoaded(response.data!));
      } else {
        print('❌ Bloc: Phát state LichHocError - ${response.message}');
        emit(LichHocError(response.message));
      }
    } catch (e, stackTrace) {
      print('❌ Bloc: Lỗi nghiêm trọng: $e');
      print('❌ Stack trace: $stackTrace');
      emit(LichHocError('Lỗi tải lịch học: ${e.toString()}'));
    }
  }

  Future<void> _onGetLichHocTheoThangNguoiHoc(
    GetLichHocTheoThangNguoiHoc event,
    Emitter<LichHocState> emit,
  ) async {
    emit(LichHocLoading());

    final ApiResponse<LichHocTheoThangResponse> response =
        await lichHocRepository.getLichHocTheoThangNguoiHoc(
          thang: event.thang,
          nam: event.nam,
          lopYeuCauId: event.lopYeuCauId,
        );

    if (response.isSuccess && response.data != null) {
      emit(LichHocTheoThangLoaded(response.data!));
    } else {
      emit(LichHocError(response.message));
    }
  }

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
      emit(LichHocTheoThangLoaded(response.data!));
    } else {
      emit(LichHocError(response.message));
    }
  }

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
