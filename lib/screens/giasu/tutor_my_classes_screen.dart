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
  const TutorMyClassesScreen({super.key});
  static const String routeName = '/tutor-my-classes';

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
    _tabController = TabController(length: 3, vsync: this);
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
            if (state is TutorClassesActionSuccess)
              _showSnack(context, state.message, Colors.green);
            else if (state is TutorClassesActionFailure)
              _showSnack(context, state.message, Colors.red);
            else if (state is TutorClassesLoadFailure)
              _showSnack(context, state.message, Colors.red);
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

  // --- LỚP ĐANG DẠY ---
  Widget _buildLopDangDayList(BuildContext context, List<LopHoc> list) {
    if (list.isEmpty)
      return _buildEmptyState('Bạn chưa có lớp học nào đang dạy');
    return RefreshIndicator(
      onRefresh:
          () async => context.read<TutorClassesBloc>().add(
            TutorClassesRefreshRequested(),
          ),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder:
            (context, index) =>
                _buildClassCard(context, list[index], isActive: true),
      ),
    );
  }

  // --- LỚP ĐÃ DẠY ---
  Widget _buildLopDaDayList(BuildContext context, List<LopHoc> list) {
    if (list.isEmpty) return _buildEmptyState('Bạn chưa có lớp đã dạy nào');
    return RefreshIndicator(
      onRefresh:
          () async => context.read<TutorClassesBloc>().add(
            TutorClassesRefreshRequested(),
          ),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder:
            (context, index) =>
                _buildClassCard(context, list[index], isActive: false),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    LopHoc lop, {
    required bool isActive,
  }) {
    final isPaid = lop.trangThaiThanhToan == 'DaThanhToan';
    final statusColor =
        isActive ? (isPaid ? Colors.green : Colors.orange) : Colors.grey;

    return GestureDetector(
      onTap: () => _navigateToClassDetail(context, lop.maLop),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 5, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isActive
                                    ? (isPaid ? 'Đang dạy' : 'Chưa thanh toán')
                                    : 'Đã kết thúc',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.person_outline, lop.tenNguoiHoc),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.attach_money,
                          '${formatNumber(toNumber(lop.hocPhi))} đ/Buổi',
                        ),
                        if (isActive && !isPaid) ...[
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.warning_amber_rounded,
                            'Phí nhận lớp: ${formatNumber(tinhPhiNhanLop(hocPhiMotBuoi: toNumber(lop.hocPhi), soBuoiMotTuan: lop.soBuoiTuan))} đ',
                            textColor: Colors.red,
                          ),
                        ],
                        const SizedBox(height: 16),

                        // CHỨC NĂNG
                        if (isActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isPaid) ...[
                                _buildActionButton(
                                  'Hủy Lịch',
                                  Icons.delete_outline,
                                  Colors.red,
                                  () => _showDeleteAllSchedulesDialog(
                                    context,
                                    lop,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  'Tạo Lịch',
                                  Icons.calendar_month_outlined,
                                  Colors.blue,
                                  () => _navigateToAddSchedule(context, lop),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  'Hoàn thành',
                                  Icons.check_circle_outline,
                                  Colors.green,
                                  () => _showCompleteClassDialog(context, lop),
                                  isPrimary: true,
                                ),
                              ] else
                                _buildActionButton(
                                  'Thanh toán',
                                  Icons.payment,
                                  Colors.orange,
                                  () => _navigateToPayment(context, lop),
                                  isPrimary: true,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- LỜI MỜI ---
  Widget _buildLopDeNghiList(
    BuildContext context,
    TutorClassesLoadSuccess state,
  ) {
    final list = state.lopDeNghi;
    if (list.isEmpty)
      return _buildEmptyState('Không có lời mời hay đề nghị nào');
    return RefreshIndicator(
      onRefresh:
          () async => context.read<TutorClassesBloc>().add(
            TutorClassesRefreshRequested(),
          ),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder:
            (context, index) => _buildRequestCard(context, list[index]),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, YeuCauNhanLop yc) {
    final isSentByMe = yc.vaiTroNguoiGui == 'GiaSu';
    final bloc = context.read<TutorClassesBloc>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    fontSize: 15,
                  ),
                  maxLines: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
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
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.attach_money,
            '${formatNumber(toNumber(yc.lopHoc.hocPhi))} đ/Buổi',
          ),
          if (yc.ghiChu?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildInfoRow(
                Icons.notes,
                yc.ghiChu!,
                textColor: Colors.grey,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                'Chi tiết',
                Icons.visibility_outlined,
                Colors.grey,
                () => _navigateToClassDetail(context, yc.lopYeuCauID),
              ),
              const SizedBox(width: 8),
              if (isSentByMe)
                _buildActionButton(
                  'Hủy',
                  Icons.close,
                  Colors.red,
                  () => bloc.add(TutorClassRequestCancelled(yc.yeuCauID)),
                )
              else ...[
                _buildActionButton(
                  'Từ chối',
                  Icons.close,
                  Colors.red,
                  () => bloc.add(TutorClassRequestRejected(yc.yeuCauID)),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  'Chấp nhận',
                  Icons.check,
                  Colors.blue,
                  () => bloc.add(TutorClassRequestConfirmed(yc.yeuCauID)),
                  isPrimary: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? textColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isPrimary ? Colors.transparent : color.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isPrimary ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) =>
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
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
            content: const Text('Hành động này không thể hoàn tác.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Thoát'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Sửa: Chỉ truyền ID (maLop)
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
