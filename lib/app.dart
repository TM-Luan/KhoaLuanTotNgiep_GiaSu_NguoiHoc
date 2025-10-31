import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Giữ nguyên import router của bạn
import 'constants/router.dart';

// === IMPORT CÁC REPOSITORY ===
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';

// === IMPORT CÁC BLOC ===
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';

class GiaSuApp extends StatelessWidget {
  const GiaSuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // === BỌC APP BẰNG CÁC PROVIDER ===
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => TutorRepository()),
        RepositoryProvider(create: (context) => LopHocRepository()),
        RepositoryProvider(create: (context) => YeuCauNhanLopRepository()),
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
          // === BLOC MỚI CHO MÀN HÌNH "LỚP CỦA TÔI" (GIA SƯ) ===
            

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
