import 'package:equatable/equatable.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop_model.dart';

abstract class TutorClassesState extends Equatable {
  const TutorClassesState();
  @override
  List<Object?> get props => [];
}

class TutorClassesLoadInProgress extends TutorClassesState {}

class TutorClassesLoadSuccess extends TutorClassesState {
  final List<LopHoc> lopDangDay;
  final List<LopHoc> lopDaDay; // THÊM BIẾN NÀY
  final List<YeuCauNhanLop> lopDeNghi;
  final Map<int, bool> actionInProgress;

  const TutorClassesLoadSuccess({
    required this.lopDangDay,
    required this.lopDaDay, // BẮT BUỘC TRUYỀN VÀO
    required this.lopDeNghi,
    this.actionInProgress = const {},
  });

  TutorClassesLoadSuccess copyWith({
    List<LopHoc>? lopDangDay,
    List<LopHoc>? lopDaDay,
    List<YeuCauNhanLop>? lopDeNghi,
    Map<int, bool>? actionInProgress,
  }) {
    return TutorClassesLoadSuccess(
      lopDangDay: lopDangDay ?? this.lopDangDay,
      lopDaDay: lopDaDay ?? this.lopDaDay,
      lopDeNghi: lopDeNghi ?? this.lopDeNghi,
      actionInProgress: actionInProgress ?? this.actionInProgress,
    );
  }

  @override
  List<Object?> get props => [
    lopDangDay,
    lopDaDay,
    lopDeNghi,
    actionInProgress,
  ];
}

class TutorClassesLoadFailure extends TutorClassesState {
  final String message;
  const TutorClassesLoadFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class TutorClassesActionSuccess extends TutorClassesState {
  final String message;
  const TutorClassesActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TutorClassesActionFailure extends TutorClassesState {
  final String message;
  const TutorClassesActionFailure(this.message);
  @override
  List<Object?> get props => [message];
}
