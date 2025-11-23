import 'package:equatable/equatable.dart';

abstract class TutorClassesEvent extends Equatable {
  const TutorClassesEvent();
  @override
  List<Object> get props => [];
}

class TutorClassesLoadStarted extends TutorClassesEvent {}

class TutorClassesRefreshRequested extends TutorClassesEvent {}

class TutorClassRequestCancelled extends TutorClassesEvent {
  final int yeuCauId;
  const TutorClassRequestCancelled(this.yeuCauId);
  @override
  List<Object> get props => [yeuCauId];
}

class TutorClassRequestConfirmed extends TutorClassesEvent {
  final int yeuCauId;
  const TutorClassRequestConfirmed(this.yeuCauId);
  @override
  List<Object> get props => [yeuCauId];
}

class TutorClassRequestRejected extends TutorClassesEvent {
  final int yeuCauId;
  const TutorClassRequestRejected(this.yeuCauId);
  @override
  List<Object> get props => [yeuCauId];
}

class TutorClassRequestUpdated extends TutorClassesEvent {
  final int yeuCauId;
  final String? ghiChu;
  const TutorClassRequestUpdated({required this.yeuCauId, this.ghiChu});
  @override
  List<Object> get props => [yeuCauId, ghiChu ?? ''];
}

// SỬA LẠI DÙNG int lopId
class TutorClassCompleted extends TutorClassesEvent {
  final int lopId;
  const TutorClassCompleted(this.lopId);
  @override
  List<Object> get props => [lopId];
}
