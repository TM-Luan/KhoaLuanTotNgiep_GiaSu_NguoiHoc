import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';
part 'tutor_event.dart';
part 'tutor_state.dart';

class TutorBloc extends Bloc<TutorEvent, TutorState> {
  final TutorRepository _tutorRepository;

  TutorBloc(this._tutorRepository) : super(TutorInitialState()) {
    on<LoadAllTutorsEvent>(_onLoadAllTutors);
    on<LoadTutorByIdEvent>(_onLoadTutorById);
    on<RefreshTutorsEvent>(_onRefreshTutors);
  }

  Future<void> _onLoadAllTutors(
    LoadAllTutorsEvent event,
    Emitter<TutorState> emit,
  ) async {
    emit(TutorLoadingState());

    final response = await _tutorRepository.getAllTutors();

    if (response.isSuccess && response.data != null) {
      emit(AllTutorsLoadedState(response.data!));
    } else {
      emit(TutorErrorState(response.message));
    }
  }

  Future<void> _onLoadTutorById(
    LoadTutorByIdEvent event,
    Emitter<TutorState> emit,
  ) async {
    emit(TutorLoadingState());

    final response = await _tutorRepository.getTutorById(event.tutorId);

    if (response.isSuccess && response.data != null) {
      emit(TutorDetailLoadedState(response.data!));
    } else {
      emit(TutorErrorState(response.message));
    }
  }

  Future<void> _onRefreshTutors(
    RefreshTutorsEvent event,
    Emitter<TutorState> emit,
  ) async {
    emit(TutorLoadingState());

    final response = await _tutorRepository.getAllTutors();

    if (response.isSuccess && response.data != null) {
      emit(AllTutorsLoadedState(response.data!));
    } else {
      emit(TutorErrorState(response.message));
    }
  }
}
