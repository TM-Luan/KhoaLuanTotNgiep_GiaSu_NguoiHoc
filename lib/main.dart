import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/app.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. THÊM IMPORT NÀY

Future<void> main() async {
  // <-- 2. THÊM 'async' VÀ 'Future<void>'

  // 3. THÊM 2 DÒNG NÀY ĐỂ KHỞI TẠO LỊCH TIẾNG VIỆT
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  // Code cũ của bạn giữ nguyên
  final authRepository = AuthRepository();
  final tutorRepository = TutorRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository)),
        BlocProvider<TutorBloc>(create: (_) => TutorBloc(tutorRepository)),
      ],
      child: const GiaSuApp(),
    ),
  );
}
