part of 'tutor_bloc.dart';

abstract class TutorEvent extends Equatable {
  const TutorEvent();

  @override
  List<Object> get props => [];
}

class LoadAllTutorsEvent extends TutorEvent {}

class LoadTutorByIdEvent extends TutorEvent {
  final int tutorId;

  const LoadTutorByIdEvent(this.tutorId);

  @override
  List<Object> get props => [tutorId];
}

class RefreshTutorsEvent extends TutorEvent {}