import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/app.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';

void main() {
  final authRepository = AuthRepository();
  final tutorRepository = TutorRepository();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository),
        ),
        BlocProvider<TutorBloc>(
          create: (_) => TutorBloc(tutorRepository),
        ),
      ],
      child: const GiaSuApp(),
    ),
  );
}