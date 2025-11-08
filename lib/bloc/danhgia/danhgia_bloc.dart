import 'package:bloc/bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/danhgia.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/danhgia_repository.dart';

part 'danhgia_event.dart';
part 'danhgia_state.dart';

class DanhGiaBloc extends Bloc<DanhGiaEvent, DanhGiaState> {
  final DanhGiaRepository danhGiaRepository;

  DanhGiaBloc(this.danhGiaRepository) : super(DanhGiaInitial()) {
    on<TaoDanhGia>(_onTaoDanhGia);
    on<LoadDanhGiaGiaSu>(_onLoadDanhGiaGiaSu);
    on<KiemTraDaDanhGia>(_onKiemTraDaDanhGia);
    on<XoaDanhGia>(_onXoaDanhGia);
  }

  Future<void> _onTaoDanhGia(
    TaoDanhGia event,
    Emitter<DanhGiaState> emit,
  ) async {
    emit(DanhGiaLoading());

    final response = await danhGiaRepository.taoDanhGia(
      giaSuId: event.giaSuId,
      diemSo: event.diemSo,
      binhLuan: event.binhLuan,
    );

    if (response.isSuccess && response.data != null) {
      emit(DanhGiaSuccess(response.message, response.data!));
    } else {
      emit(DanhGiaError(response.message));
    }
  }

  Future<void> _onLoadDanhGiaGiaSu(
    LoadDanhGiaGiaSu event,
    Emitter<DanhGiaState> emit,
  ) async {
    emit(DanhGiaLoading());

    final response = await danhGiaRepository.getDanhGiaGiaSu(
      giaSuId: event.giaSuId,
    );

    if (response.isSuccess && response.data != null) {
      emit(DanhGiaListLoaded(response.data!));
    } else {
      emit(DanhGiaError(response.message));
    }
  }

  Future<void> _onKiemTraDaDanhGia(
    KiemTraDaDanhGia event,
    Emitter<DanhGiaState> emit,
  ) async {
    emit(DanhGiaLoading());

    final response = await danhGiaRepository.kiemTraDaDanhGia(
      giaSuId: event.giaSuId,
    );

    if (response.isSuccess && response.data != null) {
      emit(KiemTraDanhGiaLoaded(response.data!));
    } else {
      emit(DanhGiaError(response.message));
    }
  }

  Future<void> _onXoaDanhGia(
    XoaDanhGia event,
    Emitter<DanhGiaState> emit,
  ) async {
    emit(DanhGiaLoading());

    final response = await danhGiaRepository.xoaDanhGia(
      danhGiaId: event.danhGiaId,
    );

    if (response.isSuccess) {
      emit(DanhGiaDeleted(response.message));
    } else {
      emit(DanhGiaError(response.message));
    }
  }
}
