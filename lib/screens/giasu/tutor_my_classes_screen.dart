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
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_add_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/payment/payment_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/utils/format_vnd.dart';

class TutorMyClassesScreen extends StatefulWidget {
  final int initialTabIndex;
  static const String routeName = '/tutor-my-classes';

  const TutorMyClassesScreen({super.key, this.initialTabIndex = 0});

  @override
  State<TutorMyClassesScreen> createState() => _TutorMyClassesScreenState();
}

class _TutorMyClassesScreenState extends State<TutorMyClassesScreen>
    with SingleTickerProviderStateMixin {
  TutorClassesLoadSuccess? _latestSuccessState;
  late StreamSubscription _proposalUpdateSubscription;
  TutorClassesBloc? _currentBloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    _proposalUpdateSubscription = GlobalNotificationService()
        .proposalUpdateStream
        .listen((event) {
          _currentBloc?.add(TutorClassesRefreshRequested());
        });
  }

  @override
  void dispose() {
    _proposalUpdateSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    int giaSuId =
        (authState is AuthAuthenticated) ? (authState.user.giaSuID ?? 0) : 0;
    int taiKhoanId =
        (authState is AuthAuthenticated) ? (authState.user.taiKhoanID ?? 0) : 0;

    if (giaSuId == 0 || taiKhoanId == 0) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập tài khoản gia sư.')),
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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Lớp học của tôi',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          // --- CUSTOM TAB BAR STYLE ---
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                indicatorPadding: const EdgeInsets.all(4),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'ĐANG DẠY'),
                  Tab(text: 'ĐÃ DẠY'),
                  Tab(text: 'LỜI MỜI'),
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
            if (state is TutorClassesLoadSuccess) _latestSuccessState = state;
            if (_latestSuccessState != null) {
              return BlocListener<LichHocBloc, LichHocState>(
                listener: (ctx, lichState) {
                  if (lichState is LichHocDeleted ||
                      lichState is LichHocCreated) {
                    ctx.read<TutorClassesBloc>().add(
                      TutorClassesRefreshRequested(),
                    );
                    _showSnack(
                      ctx,
                      lichState is LichHocDeleted
                          ? "Đã hủy lịch"
                          : "Tạo lịch thành công",
                      Colors.green,
                    );
                  }
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLopDangDayList(
                      context,
                      _latestSuccessState!.lopDangDay,
                    ),
                    _buildLopDaDayList(context, _latestSuccessState!.lopDaDay),
                    _buildLopDeNghiList(context, _latestSuccessState!),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildLopDangDayList(BuildContext context, List<LopHoc> list) {
    if (list.isEmpty)
      return _buildEmptyState('Bạn chưa có lớp học nào đang dạy', Icons.school);
    return RefreshIndicator(
      onRefresh:
          () async => context.read<TutorClassesBloc>().add(
            TutorClassesRefreshRequested(),
          ),
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder:
            (context, index) =>
                _buildClassCard(context, list[index], isActive: true),
      ),
    );
  }

  Widget _buildLopDaDayList(BuildContext context, List<LopHoc> list) {
    if (list.isEmpty)
      return _buildEmptyState('Bạn chưa có lớp đã dạy nào', Icons.history);
    return RefreshIndicator(
      onRefresh:
          () async => context.read<TutorClassesBloc>().add(
            TutorClassesRefreshRequested(),
          ),
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder:
            (context, index) =>
                _buildClassCard(context, list[index], isActive: false),
      ),
    );
  }

  Widget _buildLopDeNghiList(
    BuildContext context,
    TutorClassesLoadSuccess state,
  ) {
    final list = state.lopDeNghi;
    if (list.isEmpty)
      return _buildEmptyState(
        'Không có lời mời hay đề nghị nào',
        Icons.mail_outline,
      );
    return RefreshIndicator(
      onRefresh:
          () async => context.read<TutorClassesBloc>().add(
            TutorClassesRefreshRequested(),
          ),
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder:
            (context, index) => _buildRequestCard(context, list[index]),
      ),
    );
  }

  // --- MODERN CARD STYLES ---

  Widget _buildClassCard(
    BuildContext context,
    LopHoc lop, {
    required bool isActive,
  }) {
    final isPaid = lop.trangThaiThanhToan == 'DaThanhToan';
    // Màu status: Nếu đang dạy (Active): Xanh (Paid) hoặc Cam (Unpaid). Nếu đã xong: Xám
    final statusColor =
        isActive ? (isPaid ? Colors.green : Colors.orange) : Colors.grey;
    final statusText =
        isActive ? (isPaid ? 'Đang dạy' : 'Chưa thanh toán') : 'Đã kết thúc';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToClassDetail(context, lop.maLop),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lop.tieuDeLop,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),

              // Info Body
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person_outline, lop.tenNguoiHoc),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.monetization_on_outlined,
                      '${formatNumber(toNumber(lop.hocPhi))} đ/Buổi',
                      valueColor: Colors.black87,
                      isBold: true,
                    ),
                    if (isActive && !isPaid) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.warning_amber_rounded,
                        'Phí nhận lớp: ${formatNumber(tinhPhiNhanLop(hocPhiMotBuoi: toNumber(lop.hocPhi), soBuoiMotTuan: lop.soBuoiTuan))} đ',
                        valueColor: Colors.red,
                        isBold: true,
                      ),
                    ],
                  ],
                ),
              ),

              // Action Footer
              if (isActive)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isPaid) ...[
                        _buildSmallButton(
                          icon: Icons.delete_outline,
                          label: 'Hủy Lịch',
                          color: Colors.red.shade50,
                          textColor: Colors.red,
                          onTap:
                              () => _showDeleteAllSchedulesDialog(context, lop),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallButton(
                          icon: Icons.calendar_month_outlined,
                          label: 'Tạo Lịch',
                          color: Colors.blue.shade50,
                          textColor: Colors.blue,
                          onTap: () => _navigateToAddSchedule(context, lop),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallButton(
                          icon: Icons.check_circle_outline,
                          label: 'Hoàn thành',
                          color: Colors.green.shade50,
                          textColor: Colors.green,
                          onTap: () => _showCompleteClassDialog(context, lop),
                        ),
                      ] else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToPayment(context, lop),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.payment, size: 18),
                            label: const Text(
                              'Thanh toán phí nhận lớp',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, YeuCauNhanLop yc) {
    final isSentByMe = yc.vaiTroNguoiGui == 'GiaSu';
    final bloc = context.read<TutorClassesBloc>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    yc.lopHoc.tieuDeLop,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isSentByMe ? 'Bạn gửi' : 'Lời mời',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person_outline, yc.lopHoc.tenNguoiHoc),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.monetization_on_outlined,
              '${formatNumber(toNumber(yc.lopHoc.hocPhi))} đ/Buổi',
              valueColor: Colors.black87,
              isBold: true,
            ),
            if (yc.ghiChu?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notes, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          yc.ghiChu!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildSmallButton(
                  label: 'Chi tiết',
                  icon: Icons.visibility_outlined,
                  color: Colors.grey.shade100,
                  textColor: Colors.black87,
                  onTap: () => _navigateToClassDetail(context, yc.lopYeuCauID),
                ),
                const SizedBox(width: 8),
                if (isSentByMe)
                  _buildSmallButton(
                    label: 'Hủy',
                    icon: Icons.close,
                    color: Colors.red.shade50,
                    textColor: Colors.red,
                    onTap:
                        () => bloc.add(TutorClassRequestCancelled(yc.yeuCauID)),
                  )
                else ...[
                  _buildSmallButton(
                    label: 'Từ chối',
                    icon: Icons.close,
                    color: Colors.red.shade50,
                    textColor: Colors.red,
                    onTap:
                        () => bloc.add(TutorClassRequestRejected(yc.yeuCauID)),
                  ),
                  const SizedBox(width: 8),
                  _buildSmallButton(
                    label: 'Chấp nhận',
                    icon: Icons.check,
                    color: AppColors.primary,
                    textColor: Colors.white,
                    onTap:
                        () => bloc.add(TutorClassRequestConfirmed(yc.yeuCauID)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    Color? valueColor,
    bool isBold = false,
  }) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey.shade400),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            color: valueColor ?? Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _buildSmallButton({
    required String label,
    IconData? icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState(String msg, IconData icon) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey.shade200),
        const SizedBox(height: 16),
        Text(
          msg,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  // --- Functional Logic ---
  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _navigateToClassDetail(BuildContext ctx, int id) => Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (_) => ClassDetailScreen(classId: id, userRole: UserRole.tutor),
    ),
  );

  void _navigateToAddSchedule(BuildContext ctx, LopHoc lop) => Navigator.push(
    ctx,
    MaterialPageRoute(builder: (_) => TaoLichHocPage(lopHoc: lop)),
  );

  void _navigateToPayment(BuildContext context, LopHoc lop) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final phi = tinhPhiNhanLop(
      hocPhiMotBuoi: toNumber(lop.hocPhi),
      soBuoiMotTuan: lop.soBuoiTuan,
    );
    if (phi == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PaymentScreen(
              lopYeuCauID: lop.maLop,
              soTien: phi,
              taiKhoanID: authState.user.taiKhoanID!,
            ),
      ),
    );
    if (result == true && mounted)
      context.read<TutorClassesBloc>().add(TutorClassesRefreshRequested());
  }

  void _showDeleteAllSchedulesDialog(BuildContext context, LopHoc lop) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hủy toàn bộ lịch?'),
            content: const Text(
              'Hành động này sẽ xóa tất cả các buổi học của lớp này. Bạn có chắc chắn không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Thoát',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  context.read<LichHocBloc>().add(
                    DeleteAllLichHocLop(lopYeuCauId: lop.maLop),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Xác nhận hủy'),
              ),
            ],
          ),
    );
  }

  void _showCompleteClassDialog(BuildContext context, LopHoc lop) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hoàn thành lớp học?'),
            content: const Text(
              'Xác nhận bạn đã hoàn thành việc dạy lớp này. Lớp học sẽ được chuyển sang danh sách "Đã dạy".',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  context.read<TutorClassesBloc>().add(
                    TutorClassCompleted(lop.maLop),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }
}
