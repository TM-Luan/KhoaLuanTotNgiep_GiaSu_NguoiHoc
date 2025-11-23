import 'package:bloc/bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_state.dart';

class TutorClassesBloc extends Bloc<TutorClassesEvent, TutorClassesState> {
  final YeuCauNhanLopRepository _yeuCauNhanLopRepository;
  final int giaSuId;
  final int taiKhoanId;

  TutorClassesBloc({
    required YeuCauNhanLopRepository yeuCauNhanLopRepository,
    required this.giaSuId,
    required this.taiKhoanId,
  }) : _yeuCauNhanLopRepository = yeuCauNhanLopRepository,
       super(TutorClassesLoadInProgress()) {
    on<TutorClassesLoadStarted>(_onLoadStarted);
    on<TutorClassesRefreshRequested>(_onLoadStarted);
    on<TutorClassRequestCancelled>(_onRequestCancelled);
    on<TutorClassRequestConfirmed>(_onRequestConfirmed);
    on<TutorClassRequestRejected>(_onRequestRejected);
    on<TutorClassRequestUpdated>(_onRequestUpdated);
    on<TutorClassCompleted>(_onClassCompleted);
  }

  Future<void> _onLoadStarted(
    TutorClassesEvent event,
    Emitter<TutorClassesState> emit,
  ) async {
    await _reloadClasses(emit);
  }

  Future<void> _reloadClasses(Emitter<TutorClassesState> emit) async {
    try {
      final result = await _yeuCauNhanLopRepository.getLopCuaGiaSu(giaSuId);
      if (result.success && result.data != null) {
        final data = result.data!;

        final lopDangDay =
            (data['lopDangDay'] as List? ?? [])
                .whereType<Map<String, dynamic>>()
                .map(LopHoc.fromJson)
                .toList();

        // Handle lopDaDay safely
        final lopDaDay =
            (data['lopDaDay'] as List? ?? [])
                .whereType<Map<String, dynamic>>()
                .map(LopHoc.fromJson)
                .toList();

        final lopDeNghi =
            (data['lopDeNghi'] as List? ?? [])
                .whereType<Map<String, dynamic>>()
                .map(YeuCauNhanLop.fromJson)
                .toList();

        emit(
          TutorClassesLoadSuccess(
            lopDangDay: lopDangDay,
            lopDaDay: lopDaDay,
            lopDeNghi: lopDeNghi,
          ),
        );
      } else {
        emit(
          TutorClassesLoadFailure(
            result.message.isNotEmpty
                ? result.message
                : 'Không thể tải dữ liệu.',
          ),
        );
      }
    } catch (e) {
      emit(TutorClassesLoadFailure('Lỗi tải dữ liệu: $e'));
    }
  }

  Future<void> _onClassCompleted(
    TutorClassCompleted event,
    Emitter<TutorClassesState> emit,
  ) async {
    try {
      // Gọi repository, repository sẽ tự fetch data đầy đủ
      final response = await _yeuCauNhanLopRepository.hoanThanhLop(event.lopId);

      if (response.isSuccess) {
        emit(
          const TutorClassesActionSuccess("Đã cập nhật trạng thái hoàn thành"),
        );
        add(TutorClassesLoadStarted());
      } else {
        emit(TutorClassesActionFailure(response.message));
      }
    } catch (e) {
      emit(TutorClassesActionFailure('Lỗi: $e'));
    }
  }

  // ... (Các hàm _onRequest... giữ nguyên như cũ, không thay đổi)
  Future<void> _onRequestCancelled(
    TutorClassRequestCancelled event,
    Emitter<TutorClassesState> emit,
  ) async {
    await _handleAction(
      emit,
      yeuCauId: event.yeuCauId,
      action:
          () => _yeuCauNhanLopRepository.huyYeuCau(
            yeuCauId: event.yeuCauId,
            nguoiGuiTaiKhoanId: taiKhoanId,
          ),
      successMessage: 'Đã hủy đề nghị.',
    );
  }

  Future<void> _onRequestConfirmed(
    TutorClassRequestConfirmed event,
    Emitter<TutorClassesState> emit,
  ) async {
    await _handleAction(
      emit,
      yeuCauId: event.yeuCauId,
      action: () => _yeuCauNhanLopRepository.xacNhanYeuCau(event.yeuCauId),
      successMessage: 'Đã xác nhận đề nghị.',
    );
  }

  Future<void> _onRequestRejected(
    TutorClassRequestRejected event,
    Emitter<TutorClassesState> emit,
  ) async {
    await _handleAction(
      emit,
      yeuCauId: event.yeuCauId,
      action: () => _yeuCauNhanLopRepository.tuChoiYeuCau(event.yeuCauId),
      successMessage: 'Đã từ chối đề nghị.',
    );
  }

  Future<void> _onRequestUpdated(
    TutorClassRequestUpdated event,
    Emitter<TutorClassesState> emit,
  ) async {
    await _handleAction(
      emit,
      yeuCauId: event.yeuCauId,
      action:
          () => _yeuCauNhanLopRepository.capNhatYeuCau(
            yeuCauId: event.yeuCauId,
            nguoiGuiTaiKhoanId: taiKhoanId,
            ghiChu: event.ghiChu,
          ),
      successMessage: 'Đã cập nhật đề nghị.',
    );
  }

  Future<void> _handleAction(
    Emitter<TutorClassesState> emit, {
    required int yeuCauId,
    required Future<ApiResponse<dynamic>> Function() action,
    required String successMessage,
  }) async {
    if (state is! TutorClassesLoadSuccess) return;
    _setActionProgress(emit, yeuCauId, true);
    try {
      final response = await action();
      _setActionProgress(emit, yeuCauId, false);
      if (response.isSuccess) {
        emit(TutorClassesActionSuccess(successMessage));
        add(TutorClassesLoadStarted());
      } else {
        emit(TutorClassesActionFailure(response.message));
      }
    } catch (e) {
      _setActionProgress(emit, yeuCauId, false);
      emit(TutorClassesActionFailure('Lỗi: $e'));
    }
  }

  void _setActionProgress(
    Emitter<TutorClassesState> emit,
    int yeuCauId,
    bool inProgress,
  ) {
    final current = state;
    if (current is! TutorClassesLoadSuccess) return;
    final updated = Map<int, bool>.from(current.actionInProgress);
    if (inProgress)
      updated[yeuCauId] = true;
    else
      updated.remove(yeuCauId);
    emit(current.copyWith(actionInProgress: updated));
  }
}
