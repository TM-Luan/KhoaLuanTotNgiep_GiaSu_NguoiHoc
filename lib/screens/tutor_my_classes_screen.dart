import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';

class TutorMyClassesScreen extends StatelessWidget {
  const TutorMyClassesScreen({Key? key}) : super(key: key);

  static const String routeName = '/tutor-my-classes';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        int giaSuId = 0;

        if (authState is AuthAuthenticated) {
          // ✅ Lấy đúng ID Gia Sư đã đăng nhập
          giaSuId = authState.user.giaSuID ?? 0;
        }

       return TutorClassesBloc(
  tutorRepository: context.read<TutorRepository>(),
  lopHocRepository: context.read<LopHocRepository>(),
  yeuCauNhanLopRepository: context.read<YeuCauNhanLopRepository>(),
  giaSuId: giaSuId,
)..add(TutorClassesLoadStarted());

      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Lớp của tôi'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'ĐANG DẠY'),
                Tab(text: 'ĐỀ NGHỊ'),
              ],
            ),
          ),
          body: BlocConsumer<TutorClassesBloc, TutorClassesState>(
            listener: (context, state) {
              if (state is TutorClassesActionSuccess) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
              } else if (state is TutorClassesActionFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            builder: (context, state) {
              if (state is TutorClassesLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TutorClassesLoadFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi tải dữ liệu: ${state.message}',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<TutorClassesBloc>()
                                .add(TutorClassesLoadStarted());
                          },
                          child: const Text('Thử lại'),
                        )
                      ],
                    ),
                  ),
                );
              }
              if (state is TutorClassesLoadSuccess) {
                return TabBarView(
                  children: [
                    _buildLopDangDayList(context, state.lopDangDay),
                    _buildLopDeNghiList(context, state),
                  ],
                );
              }
              return const Center(child: Text('Trạng thái không xác định'));
            },
          ),
        ),
      ),
    );
  }

  // --- Tab 1: Lớp đang dạy ---
  Widget _buildLopDangDayList(BuildContext context, List<LopHoc> lopHocList) {
    if (lopHocList.isEmpty) {
      return const Center(child: Text('Bạn chưa có lớp học nào đang dạy.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: lopHocList.length,
        itemBuilder: (context, index) {
          final lop = lopHocList[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(lop.tieuDeLop,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Học viên: ${lop.tenNguoiHoc}'),
                  Text('Học phí: ${lop.hocPhi}'),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  // --- Tab 2: Đề nghị ---
  Widget _buildLopDeNghiList(
      BuildContext context, TutorClassesLoadSuccess state) {
    final yeuCauList = state.lopDeNghi;

    if (yeuCauList.isEmpty) {
      return const Center(child: Text('Không có đề nghị nào đang chờ.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: yeuCauList.length,
        itemBuilder: (context, index) {
          final yeuCau = yeuCauList[index];
          final bool isActionLoading =
              state.actionInProgress[yeuCau.yeuCauID] ?? false;
          return _buildRequestCard(context, yeuCau, isActionLoading);
        },
      ),
    );
  }

  // --- Card cho từng yêu cầu ---
  Widget _buildRequestCard(
      BuildContext context, YeuCauNhanLop yeuCau, bool isActionLoading) {
    final bool isSentByTutor = yeuCau.vaiTroNguoiGui == 'GiaSu';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(yeuCau.lopHoc.tieuDeLop,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Học viên: ${yeuCau.lopHoc.tenNguoiHoc}'),
            Text('Học phí: ${yeuCau.lopHoc.hocPhi}'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSentByTutor ? 'Bạn đã gửi yêu cầu' : 'Người học mời',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey[700]),
                ),
                if (isActionLoading)
                  const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  _buildActionButtons(context, yeuCau),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- Nút bấm ---
  Widget _buildActionButtons(BuildContext context, YeuCauNhanLop yeuCau) {
    final bloc = context.read<TutorClassesBloc>();

    if (yeuCau.vaiTroNguoiGui == 'GiaSu') {
      return TextButton(
        child: const Text('Hủy yêu cầu', style: TextStyle(color: Colors.red)),
        onPressed: () {
          bloc.add(TutorClassRequestCancelled(yeuCau.yeuCauID));
        },
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
            onPressed: () {
              bloc.add(TutorClassRequestRejected(yeuCau.yeuCauID));
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              bloc.add(TutorClassRequestConfirmed(yeuCau.yeuCauID));
            },
            child: const Text('Xác nhận'),
          ),
        ],
      );
    }
  }
}
