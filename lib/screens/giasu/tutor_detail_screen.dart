import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/danhgia/danhgia_dialog.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/danhgia/danhgia_list_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class TutorDetailPage extends StatefulWidget {
  static const String routeName = '/tutor-detail';
  final Tutor? tutor;
  final int? tutorId;

  const TutorDetailPage({super.key, this.tutor, this.tutorId});

  @override
  State<TutorDetailPage> createState() => _TutorDetailPageState();
}

class _TutorDetailPageState extends State<TutorDetailPage> {
  final LopHocRepository _lopHocRepository = LopHocRepository();
  bool _isProcessingInvite = false;

  @override
  void initState() {
    super.initState();
    if (widget.tutorId != null && widget.tutor == null) {
      context.read<TutorBloc>().add(LoadTutorByIdEvent(widget.tutorId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Tutor? tutorFromArgs =
        ModalRoute.of(context)?.settings.arguments as Tutor?;
    final Tutor? tutor = widget.tutor ?? tutorFromArgs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông tin Gia sư",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed:
                () => context.read<TutorBloc>().add(RefreshTutorsEvent()),
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body:
          tutor != null
              ? _buildTutorDetail(tutor)
              : BlocBuilder<TutorBloc, TutorState>(
                builder: (context, state) {
                  if (state is TutorLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TutorDetailLoadedState) {
                    return _buildTutorDetail(state.tutor);
                  }
                  if (state is TutorErrorState) {
                    return _buildErrorState(state.message);
                  }
                  return const Center(child: Text('Đang tải...'));
                },
              ),
      bottomNavigationBar: tutor != null ? _buildBottomActionBar(tutor) : null,
    );
  }

  Widget _buildTutorDetail(Tutor tutor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        100,
      ), // Padding bottom cho Action Bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Profile
          Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage:
                        tutor.image.isNotEmpty
                            ? NetworkImage(tutor.image)
                            : null,
                    child:
                        tutor.image.isEmpty
                            ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey.shade400,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tutor.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tutor.bangCap ?? 'Gia sư',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRatingSummary(tutor),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 2. Thông tin chi tiết
          _buildSectionTitle("Thông tin cá nhân"),
          _buildInfoCard([
            _buildInfoRow(Icons.email_outlined, "Email", tutor.taiKhoan.email),
            _buildInfoRow(
              Icons.phone_outlined,
              "Điện thoại",
              tutor.taiKhoan.soDienThoai,
            ),
            _buildInfoRow(
              Icons.location_on_outlined,
              "Địa chỉ",
              tutor.diaChi ?? "Chưa cập nhật",
            ),
            _buildInfoRow(
              Icons.cake_outlined,
              "Ngày sinh",
              _formatDate(tutor.ngaySinh),
            ),
            _buildInfoRow(
              Icons.person_outline,
              "Giới tính",
              tutor.gioiTinh ?? "Chưa cập nhật",
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle("Học vấn & Kinh nghiệm"),
          _buildInfoCard([
            _buildInfoRow(
              Icons.school_outlined,
              "Trường ĐT",
              tutor.truongDaoTao,
            ),
            _buildInfoRow(
              Icons.book_outlined,
              "Chuyên ngành",
              tutor.chuyenNganh,
            ),
            _buildInfoRow(Icons.work_outline, "Kinh nghiệm", tutor.kinhNghiem),
          ]),

          if (tutor.thanhTich != null && tutor.thanhTich!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle("Thành tích nổi bật"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.amber.shade800,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tutor.thanhTich!,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(Tutor tutor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DanhGiaListScreen(tutor: tutor),
                      ),
                    ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Xem đánh giá",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _isProcessingInvite ? null : () => _showOfferDialog(tutor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isProcessingInvite
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "Mời dạy ngay",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildRatingSummary(Tutor tutor) {
    return InkWell(
      onTap: () => _showRatingDialog(tutor), // Nhấn vào để đánh giá nhanh
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              tutor.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "(${tutor.tongSoDanhGia} đánh giá)",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 12, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            Text(
              "Đánh giá ngay",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Nền xám rất nhạt
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text('Lỗi: $message', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              if (widget.tutorId != null) {
                context.read<TutorBloc>().add(
                  LoadTutorByIdEvent(widget.tutorId!),
                );
              }
            },
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "Chưa cập nhật";
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // --- Logic Handlers (Giữ nguyên 99% logic cũ, chỉ clean code) ---

  void _showOfferDialog(Tutor tutor) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user.nguoiHocID == null) {
      _showSnack('Vui lòng đăng nhập học viên để mời dạy', true);
      return;
    }
    _loadClassesAndPrompt(authState, tutor);
  }

  Future<void> _loadClassesAndPrompt(
    AuthAuthenticated auth,
    Tutor tutor,
  ) async {
    setState(() => _isProcessingInvite = true);
    final response = await _lopHocRepository.getLopHocCuaNguoiHoc();
    setState(() => _isProcessingInvite = false);

    if (!mounted || !response.isSuccess || response.data == null) return;

    final availableClasses =
        response.data!
            .where(
              (l) => [
                'TIMGIASU',
                'CHODUYET',
              ].contains((l.trangThai ?? '').toUpperCase()),
            )
            .toList();
    if (availableClasses.isEmpty) {
      _showSnack('Bạn chưa có lớp nào để mời.', true);
      return;
    }

    int selectedClassId = availableClasses.first.maLop;
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mời gia sư ${tutor.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: selectedClassId,
                  decoration: InputDecoration(
                    labelText: 'Chọn lớp',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items:
                      availableClasses
                          .map(
                            (l) => DropdownMenuItem(
                              value: l.maLop,
                              child: Text(
                                l.tieuDeLop,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => selectedClassId = v!,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Lời nhắn (Tuỳ chọn)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.pop(ctx, {
                          'classId': selectedClassId,
                          'note': noteController.text,
                        }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Gửi lời mời',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    if (result != null) {
      _sendInvite(
        tutor: tutor,
        lopId: result['classId'],
        ghiChu: result['note'],
        auth: auth,
      );
    }
  }

  Future<void> _sendInvite({
    required Tutor tutor,
    required int lopId,
    required String? ghiChu,
    required AuthAuthenticated auth,
  }) async {
    setState(() => _isProcessingInvite = true);
    final res = await context.read<YeuCauNhanLopRepository>().nguoiHocMoiGiaSu(
      lopId: lopId,
      giaSuId: tutor.giaSuID,
      nguoiGuiTaiKhoanId: auth.user.taiKhoanID!,
      ghiChu: ghiChu,
    );
    setState(() => _isProcessingInvite = false);
    if (mounted) _showSnack(res.message, !res.isSuccess);
  }

  void _showRatingDialog(Tutor tutor) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user.nguoiHocID == null) {
      _showSnack('Vui lòng đăng nhập học viên để đánh giá', true);
      return;
    }

    // ... (Giữ nguyên logic kiểm tra quyền đánh giá của bạn) ...
    // Để ngắn gọn, mình gọi thẳng dialog ở đây, bạn copy lại logic check cũ nhé.
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DanhGiaGiaSuDialog(tutor: tutor),
    );

    if (result == true && mounted) {
      context.read<TutorBloc>().add(LoadTutorByIdEvent(tutor.giaSuID));
      _showSnack('Đánh giá thành công!', false);
    }
  }

  void _showSnack(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
