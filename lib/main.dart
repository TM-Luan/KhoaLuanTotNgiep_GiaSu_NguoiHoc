import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/app.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';

void main() {
  final authRepository = AuthRepository();
  runApp(
    BlocProvider(
      create: (_) => AuthBloc(authRepository),
      child: const GiaSuApp(),
    ),
  );
}
