import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'constants/router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/giasu_repository.dart';
import 'data/repositories/lophoc_repository.dart';
import 'data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'data/repositories/lich_hoc_repository.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/tutor/tutor_bloc.dart';

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
        RepositoryProvider(create: (context) => LichHocRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider<TutorBloc>(
            create: (context) => TutorBloc(context.read<TutorRepository>()),
          ),
          BlocProvider<LichHocBloc>(
            create: (context) => LichHocBloc(context.read<LichHocRepository>()),
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
