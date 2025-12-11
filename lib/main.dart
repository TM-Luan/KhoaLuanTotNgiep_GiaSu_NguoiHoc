import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/app.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/danhgia/danhgia_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/auth_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/danhgia_repository.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:firebase_core/firebase_core.dart'; // Import này
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/firebase_options.dart';
import 'services/fcm_service.dart'; // Import service vừa tạo
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FCMService.init();
  await initializeDateFormatting('vi_VN', null);

  // Code cũ của bạn giữ nguyên
  final authRepository = AuthRepository();
  final tutorRepository = TutorRepository();
  final danhGiaRepository = DanhGiaRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository)),
        BlocProvider<TutorBloc>(create: (_) => TutorBloc(tutorRepository)),
        BlocProvider<DanhGiaBloc>(create: (_) => DanhGiaBloc(danhGiaRepository)),
      ],
      child: const GiaSuApp(),
    ),
  );
}
