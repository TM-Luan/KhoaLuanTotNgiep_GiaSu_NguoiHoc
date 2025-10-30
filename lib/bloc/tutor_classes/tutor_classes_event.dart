import 'package:equatable/equatable.dart';

abstract class TutorClassesEvent extends Equatable {
  const TutorClassesEvent();

  @override
  List<Object> get props => [];
}

// Tải dữ liệu ban đầu
class TutorClassesLoadStarted extends TutorClassesEvent {}

// Làm mới (pull to refresh)
class TutorClassesRefreshRequested extends TutorClassesEvent {}

// Gia sư hủy yêu cầu đã gửi
class TutorClassRequestCancelled extends TutorClassesEvent {
  final int yeuCauId;
  const TutorClassRequestCancelled(this.yeuCauId);
  @override
  List<Object> get props => [yeuCauId];
}

// Gia sư xác nhận lời mời
class TutorClassRequestConfirmed extends TutorClassesEvent {
  final int yeuCauId;
  const TutorClassRequestConfirmed(this.yeuCauId);
  @override
  List<Object> get props => [yeuCauId];
}

// Gia sư từ chối lời mời
class TutorClassRequestRejected extends TutorClassesEvent {
  final int yeuCauId;
  const TutorClassRequestRejected(this.yeuCauId);
  @override
  List<Object> get props => [yeuCauId];
}
