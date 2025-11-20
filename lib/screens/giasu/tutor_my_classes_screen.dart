// file: lib/screens/giasu/tutor_my_classes_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/lichhoc/lich_hoc_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor_classes/tutor_classes_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_add_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/payment/payment_screen.dart'; // Import màn hình thanh toán
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_info_row.dart';

class TutorMyClassesScreen extends StatefulWidget {
  const TutorMyClassesScreen({super.key});

  static const String routeName = '/tutor-my-classes';

  @override
  State<TutorMyClassesScreen> createState() => _TutorMyClassesScreenState();
}

class _TutorMyClassesScreenState extends State<TutorMyClassesScreen> {
  TutorClassesLoadSuccess? _latestSuccessState;
  late StreamSubscription<ProposalUpdateEvent> _proposalUpdateSubscription;
  TutorClassesBloc? _currentBloc;

  @override
  void initState() {
    super.initState();
    _proposalUpdateSubscription = GlobalNotificationService()
        .proposalUpdateStream
        .listen((event) {
          if (_currentBloc != null) {
            _currentBloc!.add(TutorClassesRefreshRequested());
          }
        });
  }

  @override
  void dispose() {
    _proposalUpdateSubscription.cancel();
    super.dispose();
  }

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
          child: Text(
            'Vui lòng đăng nhập bằng tài khoản gia sư để xem dữ liệu.',
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) {
        _currentBloc = TutorClassesBloc(
          yeuCauNhanLopRepository: context.read<YeuCauNhanLopRepository>(),
          giaSuId: giaSuId,
          taiKhoanId: taiKhoanId,
        )..add(TutorClassesLoadStarted());
        return _currentBloc!;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(
                    Icons.school,
                    color: AppColors.primary,
                    size: AppSpacing.iconSize,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Lớp của tôi',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTypography.appBarTitle,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Container(
                color: AppColors.grey100,
                child: TabBar(
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTypography.body2,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 18),
                          const SizedBox(width: 8),
                          const Text('ĐANG DẠY'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pending_actions, size: 18),
                          const SizedBox(width: 8),
                          const Text('ĐỀ NGHỊ'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

              return const Center(
                child: Text('Hiện chưa có dữ liệu hiển thị.'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, TutorClassesLoadSuccess state) {
    return BlocListener<LichHocBloc, LichHocState>(
      listenWhen: (previous, current) {
        return current is LichHocDeleted ||
            current is LichHocCreated ||
            current is LichHocError;
      },
      listener: (context, state) {
        if (state is LichHocDeleted) {
          _showSnack(context, state.message, Colors.green);
          context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
        } else if (state is LichHocCreated) {
          _showSnack(context, "Tạo lịch thành công", Colors.green);
          context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
        } else if (state is LichHocError) {
          _showSnack(context, state.message, Colors.red);
        }
      },
      child: TabBarView(
        children: [
          _buildLopDangDayList(context, state.lopDangDay),
          _buildLopDeNghiList(context, state),
        ],
      ),
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

  // --- Lớp Đang Dạy (Có logic thanh toán) ---
  Widget _buildLopDangDayList(BuildContext context, List<LopHoc> lopHocList) {
    if (lopHocList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa có lớp học nào đang dạy',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lopHocList.length,
        itemBuilder: (context, index) {
          final lop = lopHocList[index];

          final Color cardColor = Colors.blue.shade50;
          final Color statusColor = Colors.blue.shade100;
          final Color textColor = Colors.blue.shade700;
          final IconData statusIcon = Icons.send_outlined;

          // KIỂM TRA TRẠNG THÁI THANH TOÁN
          // Nếu trường này null hoặc không phải 'DaThanhToan', coi như chưa thanh toán
          final bool isPaid = lop.trangThaiThanhToan == 'DaThanhToan';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardColor, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(statusIcon, color: textColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lop.tieuDeLop,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // BADGE TRẠNG THÁI
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isPaid
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isPaid ? 'Đang dạy' : 'Chưa thanh toán',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color:
                                  isPaid
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InfoRow(
                      icon: Icons.person,
                      label: 'Học viên',
                      value: lop.tenNguoiHoc,
                    ),
                    const SizedBox(height: 6),
                    InfoRow(
                      icon: Icons.attach_money,
                      label: 'Học phí',
                      value: '${formatNumber(toNumber(lop.hocPhi))} VNĐ/Buổi',
                    ),

                    // Hiển thị thêm thông tin phí nếu chưa thanh toán
                    if (!isPaid) ...[
                      const SizedBox(height: 6),
                      InfoRow(
                        icon: Icons.payment,
                        label: 'Phí nhận lớp',
                        value:
                            '${formatNumber(tinhPhiNhanLop(hocPhiMotBuoi: toNumber(lop.hocPhi), soBuoiMotTuan: lop.soBuoiTuan))} VNĐ',
                        valueStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    if (lop.diaChi?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
                      InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Địa chỉ',
                        value: lop.diaChi!,
                      ),
                    ],
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildActionButton(
                          context: context,
                          label: 'Chi tiết',
                          icon: Icons.visibility,
                          color: Colors.blue.shade600,
                          onPressed:
                              () => _navigateToClassDetail(context, lop.maLop),
                        ),

                        // LOGIC ẨN HIỆN NÚT
                        if (isPaid) ...[
                          _buildActionButton(
                            context: context,
                            label: 'Tạo Lịch',
                            icon: Icons.schedule,
                            color: Colors.green.shade600,
                            onPressed:
                                () => _navigateToAddSchedule(context, lop),
                          ),
                          _buildActionButton(
                            context: context,
                            label: 'Hủy Lịch',
                            icon: Icons.delete_sweep_outlined,
                            color: Colors.red.shade600,
                            onPressed:
                                () =>
                                    _showDeleteAllSchedulesDialog(context, lop),
                          ),
                        ] else ...[
                          // Nút thanh toán nếu chưa trả phí
                          _buildActionButton(
                            context: context,
                            label: 'Thanh toán phí',
                            icon: Icons.payment_outlined,
                            color: Colors.orange.shade700,
                            onPressed: () => _navigateToPayment(context, lop),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // --- Lớp Đề Nghị ---
  Widget _buildLopDeNghiList(
    BuildContext context,
    TutorClassesLoadSuccess state,
  ) {
    final yeuCauList = state.lopDeNghi;
    if (yeuCauList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.request_page_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có đề nghị nào đang chờ',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
    final Color cardColor =
        isSentByTutor ? Colors.blue.shade50 : Colors.orange.shade50;
    final Color statusColor =
        isSentByTutor ? Colors.blue.shade100 : Colors.orange.shade100;
    final Color textColor =
        isSentByTutor ? Colors.blue.shade700 : Colors.orange.shade700;
    final IconData statusIcon =
        isSentByTutor ? Icons.send_outlined : Icons.mail_outline;
    final String footerText = isSentByTutor ? 'Bạn đã gửi' : 'Mời bạn';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(statusIcon, color: textColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      yeuCau.lopHoc.tieuDeLop,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      yeuCau.trangThai,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoRow(
                icon: Icons.person,
                label: 'Học viên',
                value: yeuCau.lopHoc.tenNguoiHoc,
              ),
              const SizedBox(height: 6),
              InfoRow(
                icon: Icons.attach_money,
                label: 'Học phí',
                value:
                    '${formatNumber(toNumber(yeuCau.lopHoc.hocPhi))} VNĐ/Buổi',
              ),
              if (yeuCau.lopHoc.diaChi?.isNotEmpty ?? false) ...[
                const SizedBox(height: 6),
                InfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Địa chỉ',
                  value: yeuCau.lopHoc.diaChi!,
                ),
              ],
              if (yeuCau.ghiChu?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.note,
                  label: 'Ghi chú',
                  value: yeuCau.ghiChu!,
                  iconColor: Colors.grey.shade600,
                  iconSize: 16,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  valueStyle: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 12),

              if (isActionLoading)
                const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        footerText,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(child: _buildActionButtons(context, yeuCau)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, YeuCauNhanLop yeuCau) {
    final bloc = context.read<TutorClassesBloc>();
    final bool isSentByTutor = yeuCau.vaiTroNguoiGui == 'GiaSu';
    final authState = context.read<AuthBloc>().state;
    int currentTaiKhoanId = 0;
    if (authState is AuthAuthenticated) {
      currentTaiKhoanId = authState.user.taiKhoanID ?? 0;
    }
    final bool isOwnRequest = yeuCau.nguoiGuiTaiKhoanID == currentTaiKhoanId;

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildOutlineActionButton(
          label: 'Chi tiết',
          icon: Icons.visibility,
          color: Colors.green.shade700,
          borderColor: Colors.green.shade300,
          onTap: () => _navigateToClassDetail(context, yeuCau.lopYeuCauID),
        ),

        if (isSentByTutor) ...[
          if (isOwnRequest) ...[
            _buildOutlineActionButton(
              label: 'Sửa',
              icon: Icons.edit,
              color: Colors.blue.shade700,
              borderColor: Colors.blue.shade300,
              onTap: () => _showUpdateNoteDialog(context, yeuCau),
            ),
            _buildOutlineActionButton(
              label: 'Hủy',
              icon: Icons.cancel,
              color: Colors.red.shade700,
              borderColor: Colors.red.shade300,
              onTap:
                  () => bloc.add(TutorClassRequestCancelled(yeuCau.yeuCauID)),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Session khác',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ] else ...[
          _buildOutlineActionButton(
            label: 'Từ chối',
            icon: Icons.close,
            color: Colors.red.shade700,
            borderColor: Colors.red.shade300,
            onTap: () => bloc.add(TutorClassRequestRejected(yeuCau.yeuCauID)),
          ),
          _buildOutlineActionButton(
            label: 'Chấp nhận',
            icon: Icons.check,
            color: Colors.blue.shade700,
            borderColor: Colors.blue.shade300,
            onTap: () => bloc.add(TutorClassRequestConfirmed(yeuCau.yeuCauID)),
          ),
        ],
      ],
    );
  }

  Widget _buildOutlineActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _navigateToClassDetail(BuildContext context, int lopHocId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ClassDetailScreen(classId: lopHocId, userRole: UserRole.tutor),
      ),
    );
  }

  // Hàm điều hướng sang trang thanh toán
  void _navigateToPayment(BuildContext context, LopHoc lop) async {
    final authState = context.read<AuthBloc>().state;
    int taiKhoanId = 0;
    if (authState is AuthAuthenticated) {
      taiKhoanId = authState.user.taiKhoanID ?? 0;
    }

    if (taiKhoanId == 0) {
      _showSnack(
        context,
        'Lỗi: Không tìm thấy thông tin tài khoản',
        Colors.red,
      );
      return;
    }

    final double? hocPhi = toNumber(lop.hocPhi);
    final int? soBuoi = lop.soBuoiTuan;
    final double? phiNhanLop = tinhPhiNhanLop(
      hocPhiMotBuoi: hocPhi,
      soBuoiMotTuan: soBuoi,
    );

    if (phiNhanLop == null || phiNhanLop <= 0) {
      _showSnack(context, 'Lỗi: Không thể tính phí nhận lớp', Colors.red);
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentScreen(
              lopYeuCauID: lop.maLop,
              soTien: phiNhanLop,
              taiKhoanID: taiKhoanId,
            ),
      ),
    );

    if (result == true) {
      if (mounted) {
        context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
      }
    }
  }

  void _navigateToAddSchedule(BuildContext context, LopHoc lop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaoLichHocPage(lopHoc: lop)),
    );
  }

  void _showDeleteAllSchedulesDialog(BuildContext context, LopHoc lop) {
    final lichHocBloc = context.read<LichHocBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận hủy lịch'),
          content: Text(
            'Bạn có chắc chắn hủy lịch học đã tạo cho lớp "${lop.tieuDeLop}" không? \n\nHành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              child: const Text('Thoát'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Xác nhận hủy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                lichHocBloc.add(DeleteAllLichHocLop(lopYeuCauId: lop.maLop));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
