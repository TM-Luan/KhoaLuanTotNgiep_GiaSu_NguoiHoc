// app.dart - CẬP NHẬT
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'constants/router.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lich_hoc_repository.dart'; // THÊM
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';


class GiaSuApp extends StatelessWidget {
  const GiaSuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => TutorRepository()),
        RepositoryProvider(create: (context) => LopHocRepository()),
        RepositoryProvider(create: (context) => YeuCauNhanLopRepository()),
        RepositoryProvider(create: (context) => LichHocRepository()), // THÊM
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoC xác thực
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              context.read<AuthRepository>(),
            ),
          ),
          // BLoC quản lý gia sư (chung)
          BlocProvider<TutorBloc>(
            create: (context) => TutorBloc(
              context.read<TutorRepository>(),
            ),
          ),
          // === BLOC MỚI CHO LỊCH HỌC ===
          BlocProvider<LichHocBloc>(
            create: (context) => LichHocBloc(
              context.read<LichHocRepository>(),
            ),
          ),
        ],
        child: SafeArea(
          child: MaterialApp(
            title: 'Gia Sư - Kết nối người học',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
            initialRoute: '/splash',
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      ),
    );
  }
}