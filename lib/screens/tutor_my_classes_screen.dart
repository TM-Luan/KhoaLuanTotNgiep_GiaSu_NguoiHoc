import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';

class TutorMyClassesScreen extends StatefulWidget {
  const TutorMyClassesScreen({Key? key}) : super(key: key);

  static const String routeName = '/tutor-my-classes';

  @override
  State<TutorMyClassesScreen> createState() => _TutorMyClassesScreenState();
}

class _TutorMyClassesScreenState extends State<TutorMyClassesScreen> {
  TutorClassesLoadSuccess? _latestSuccessState;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    int giaSuId = 0;
    int taiKhoanId = 0;

    if (authState is AuthAuthenticated) {
      giaSuId = authState.user.giaSuID ?? 0;
      taiKhoanId = authState.user.taiKhoanID ?? 0;
    }

    if (giaSuId == 0 || taiKhoanId == 0) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập bằng tài khoản gia sư để xem dữ liệu.'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => TutorClassesBloc(
        yeuCauNhanLopRepository: context.read<YeuCauNhanLopRepository>(),
        giaSuId: giaSuId,
        taiKhoanId: taiKhoanId,
      )..add(TutorClassesLoadStarted()),
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
                _showSnack(context, state.message, Colors.green);
              } else if (state is TutorClassesActionFailure) {
                _showSnack(context, state.message, Colors.red);
              } else if (state is TutorClassesLoadFailure) {
                _showSnack(context, state.message, Colors.red);
              }
            },
            builder: (context, state) {
              if (state is TutorClassesLoadSuccess) {
                _latestSuccessState = state;
              } else if (state is TutorClassesLoadFailure) {
                _latestSuccessState = null;
              }

              if (state is TutorClassesLoadFailure) {
                return _buildErrorState(context, state.message);
              }

              if (_latestSuccessState != null) {
                final showLoadingOverlay = state is TutorClassesLoadInProgress;

                return Stack(
                  children: [
                    _buildTabs(context, _latestSuccessState!),
                    if (showLoadingOverlay)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                );
              }

              if (state is TutorClassesLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }

              return const Center(child: Text('Hiện chưa có dữ liệu hiển thị.'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, TutorClassesLoadSuccess state) {
    return TabBarView(
      children: [
        _buildLopDangDayList(context, state.lopDangDay),
        _buildLopDeNghiList(context, state),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi tải dữ liệu: $message', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<TutorClassesBloc>().add(TutorClassesLoadStarted());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

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
              title: Text(
                lop.tieuDeLop,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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

  Widget _buildLopDeNghiList(
    BuildContext context,
    TutorClassesLoadSuccess state,
  ) {
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

  Widget _buildRequestCard(
    BuildContext context,
    YeuCauNhanLop yeuCau,
    bool isActionLoading,
  ) {
    final bool isSentByTutor = yeuCau.vaiTroNguoiGui == 'GiaSu';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              yeuCau.lopHoc.tieuDeLop,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('Học viên: ${yeuCau.lopHoc.tenNguoiHoc}'),
            Text('Học phí: ${yeuCau.lopHoc.hocPhi}'),
            if (yeuCau.ghiChu?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text('Ghi chú: ${yeuCau.ghiChu}')
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSentByTutor
                          ? 'Bạn đã gửi đề nghị'
                          : 'Người học mời',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trạng thái: ${yeuCau.trangThai}',
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
                if (isActionLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  _buildActionButtons(context, yeuCau),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, YeuCauNhanLop yeuCau) {
    final bloc = context.read<TutorClassesBloc>();
    final bool isSentByTutor = yeuCau.vaiTroNguoiGui == 'GiaSu';

    if (isSentByTutor) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _showUpdateNoteDialog(context, yeuCau),
            child: const Text('Sửa'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => bloc.add(TutorClassRequestCancelled(yeuCau.yeuCauID)),
            child: const Text('Hủy', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => bloc.add(TutorClassRequestRejected(yeuCau.yeuCauID)),
          child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () => bloc.add(TutorClassRequestConfirmed(yeuCau.yeuCauID)),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }

  Future<void> _showUpdateNoteDialog(
    BuildContext context,
    YeuCauNhanLop yeuCau,
  ) async {
    final controller = TextEditingController(text: yeuCau.ghiChu ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cập nhật ghi chú đề nghị'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú cho đề nghị...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').length > 500) {
                  return 'Ghi chú tối đa 500 ký tự';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      context.read<TutorClassesBloc>().add(
            TutorClassRequestUpdated(
              yeuCauId: yeuCau.yeuCauID,
              ghiChu: result.isEmpty ? null : result,
            ),
          );
    }
  }

  void _showSnack(BuildContext context, String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
  }
}
