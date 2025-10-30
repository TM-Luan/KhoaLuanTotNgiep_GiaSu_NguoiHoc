import 'package:bloc/bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_state.dart';

class TutorClassesBloc extends Bloc<TutorClassesEvent, TutorClassesState> {
  final TutorRepository _tutorRepository;
  final LopHocRepository _lopHocRepository;
  final YeuCauNhanLopRepository _yeuCauNhanLopRepository;
  final int giaSuId; // ✅ ID gia sư hiện tại

  TutorClassesBloc({
    required TutorRepository tutorRepository,
    required LopHocRepository lopHocRepository,
    required YeuCauNhanLopRepository yeuCauNhanLopRepository,
    required this.giaSuId,
  })  : _tutorRepository = tutorRepository,
        _lopHocRepository = lopHocRepository,
        _yeuCauNhanLopRepository = yeuCauNhanLopRepository,
        super(TutorClassesLoadInProgress()) {
    on<TutorClassesLoadStarted>(_onLoadStarted);
    on<TutorClassesRefreshRequested>(_onLoadStarted);
  }

  // === Gọi API /api/giasu/{id}/lop ===
  Future<void> _onLoadStarted(
    TutorClassesEvent event,
    Emitter<TutorClassesState> emit,
  ) async {
    emit(TutorClassesLoadInProgress());

    try {
      final result = await _tutorRepository.getTutorClasses(giaSuId);

      if (result.success && result.data != null) {
        final data = result.data!;
        print('📦 Dữ liệu trả về từ API: $data');

        final lopDangDay = (data['dang_day'] as List? ?? [])
            .map((e) => LopHoc.fromJson(e as Map<String, dynamic>))
            .toList();

        final lopDeNghi = (data['de_nghi'] as List? ?? [])
            .map((e) => YeuCauNhanLop.fromJson(e as Map<String, dynamic>))
            .toList();

        emit(TutorClassesLoadSuccess(
          lopDangDay: lopDangDay,
          lopDeNghi: lopDeNghi,
        ));
      } else {
        emit(TutorClassesLoadFailure(result.message));
      }
    } catch (e, stack) {
      print('❌ Lỗi khi tải dữ liệu lớp: $e');
      print(stack);
      emit(TutorClassesLoadFailure('Lỗi tải dữ liệu: $e'));
    }
  }
}
