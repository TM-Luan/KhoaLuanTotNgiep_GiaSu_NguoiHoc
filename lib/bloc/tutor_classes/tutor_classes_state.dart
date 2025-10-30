import 'package:equatable/equatable.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop.dart';

abstract class TutorClassesState extends Equatable {
  const TutorClassesState();
  @override
  List<Object?> get props => [];
}

// Đang tải dữ liệu
class TutorClassesLoadInProgress extends TutorClassesState {}

// Tải dữ liệu thành công
class TutorClassesLoadSuccess extends TutorClassesState {
  final List<LopHoc> lopDangDay;
  final List<YeuCauNhanLop> lopDeNghi;
  final Map<int, bool> actionInProgress;

  const TutorClassesLoadSuccess({
    required this.lopDangDay,
    required this.lopDeNghi,
    this.actionInProgress = const {},
  });

  TutorClassesLoadSuccess copyWith({
    List<LopHoc>? lopDangDay,
    List<YeuCauNhanLop>? lopDeNghi,
    Map<int, bool>? actionInProgress,
  }) {
    return TutorClassesLoadSuccess(
      lopDangDay: lopDangDay ?? this.lopDangDay,
      lopDeNghi: lopDeNghi ?? this.lopDeNghi,
      actionInProgress: actionInProgress ?? this.actionInProgress,
    );
  }

  @override
  List<Object?> get props => [lopDangDay, lopDeNghi, actionInProgress];
}

// Lỗi khi tải
class TutorClassesLoadFailure extends TutorClassesState {
  final String message;
  const TutorClassesLoadFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hành động thành công (để hiện SnackBar)
class TutorClassesActionSuccess extends TutorClassesState {
  final String message;
  const TutorClassesActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Hành động thất bại
class TutorClassesActionFailure extends TutorClassesState {
  final String message;
  const TutorClassesActionFailure(this.message);
  @override
  List<Object?> get props => [message];
}
