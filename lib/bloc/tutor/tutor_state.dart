part of 'tutor_bloc.dart';

abstract class TutorState extends Equatable {
  const TutorState();

  @override
  List<Object> get props => [];
}

class TutorInitialState extends TutorState {}

class TutorLoadingState extends TutorState {}

class AllTutorsLoadedState extends TutorState {
  final List<Tutor> tutors;

  const AllTutorsLoadedState(this.tutors);

  @override
  List<Object> get props => [tutors];
}

class TutorDetailLoadedState extends TutorState {
  final Tutor tutor;

  const TutorDetailLoadedState(this.tutor);

  @override
  List<Object> get props => [tutor];
}

class TutorErrorState extends TutorState {
  final String message;

  const TutorErrorState(this.message);

  @override
  List<Object> get props => [message];
}