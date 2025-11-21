// Imports giữ nguyên
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';

class StudentClassProposalsScreen extends StatefulWidget {
  final int lopHocId;
  const StudentClassProposalsScreen({super.key, required this.lopHocId});

  @override
  State<StudentClassProposalsScreen> createState() =>
      _StudentClassProposalsScreenState();
}

class _StudentClassProposalsScreenState
    extends State<StudentClassProposalsScreen> {
  late final YeuCauNhanLopRepository _yeuCauRepo;
  int? _taiKhoanId;
  bool _isLoading = true;
  String? _errorMessage;
  List<YeuCauNhanLop> _proposals = [];
  final Map<int, bool> _actionInProgress = {};

  @override
  void initState() {
    super.initState();
    _yeuCauRepo = context.read<YeuCauNhanLopRepository>();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _taiKhoanId = authState.user.taiKhoanID;
    }
    _loadProposals();
  }

  // ... Giữ nguyên logic _loadProposals, _setActionProgress, _performAction, _showSnack ...
  Future<void> _loadProposals({bool showLoader = true}) async {
    if (!mounted) return;
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await _yeuCauRepo.getDeNghiTheoLop(widget.lopHocId);
      if (!mounted) return;
      if (response.isSuccess && response.data != null) {
        setState(() {
          _proposals = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  void _setActionProgress(int yeuCauId, bool inProgress) {
    setState(() {
      if (inProgress) {
        _actionInProgress[yeuCauId] = true;
      } else {
        _actionInProgress.remove(yeuCauId);
      }
    });
  }

  Future<void> _performAction({
    required int yeuCauId,
    required Future<ApiResponse<dynamic>> Function() action,
    required String successMessage,
    String? actionType,
  }) async {
    if (!mounted) return;
    _setActionProgress(yeuCauId, true);
    try {
      final response = await action();
      if (!mounted) return;
      _setActionProgress(yeuCauId, false);
      if (response.isSuccess) {
        _showSnack(successMessage, false);
        await _loadProposals(showLoader: false);
        // Logic notification giữ nguyên...
        if (actionType == 'accept') {
          final proposal = _proposals.firstWhere((p) => p.yeuCauID == yeuCauId);
          if (proposal.giaSuID != null) {
            GlobalNotificationService().notifyProposalAccepted(
              proposalId: yeuCauId,
              classId: widget.lopHocId,
              tutorId: proposal.giaSuID!,
            );
          }
        } else if (actionType == 'reject') {
          final proposal = _proposals.firstWhere((p) => p.yeuCauID == yeuCauId);
          if (proposal.giaSuID != null) {
            GlobalNotificationService().notifyProposalRejected(
              proposalId: yeuCauId,
              classId: widget.lopHocId,
              tutorId: proposal.giaSuID!,
            );
          }
        }
      } else {
        _showSnack(
          response.message.isNotEmpty ? response.message : 'Thất bại',
          true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _setActionProgress(yeuCauId, false);
      _showSnack('Lỗi: $e', true);
    }
  }

  void _showSnack(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: Text(
          'Đề nghị (Lớp ${widget.lopHocId})',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: TextButton(
          onPressed: () => _loadProposals(),
          child: const Text('Thử lại'),
        ),
      );
    }

    if (_proposals.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có đề nghị nào.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProposals(showLoader: false),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _proposals.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final yeuCau = _proposals[index];
          final isLoading = _actionInProgress[yeuCau.yeuCauID] ?? false;
          return _buildProposalCard(yeuCau, isLoading);
        },
      ),
    );
  }

  Widget _buildProposalCard(YeuCauNhanLop yeuCau, bool isLoading) {
    final bool isPending = yeuCau.isPending;
    final bool sentByTutor = yeuCau.vaiTroNguoiGui == 'GiaSu';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  yeuCau.lopHoc.tieuDeLop,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isPending
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  yeuCau.trangThai,
                  style: TextStyle(
                    color: isPending ? Colors.orange : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFF5F5F5),
                child: Icon(Icons.person, size: 16, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                yeuCau.giaSuHoTen ?? 'Ẩn danh',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          if (yeuCau.ghiChu?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      yeuCau.ghiChu!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (yeuCau.giaSuID != null)
                TextButton.icon(
                  icon: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Chi tiết GV',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TutorDetailPage(tutorId: yeuCau.giaSuID!),
                        ),
                      ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),

              if (isPending)
                isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : _buildActionButtons(yeuCau, sentByTutor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(YeuCauNhanLop yeuCau, bool sentByTutor) {
    if (sentByTutor) {
      return Row(
        children: [
          OutlinedButton(
            onPressed:
                () => _performAction(
                  yeuCauId: yeuCau.yeuCauID,
                  action: () => _yeuCauRepo.tuChoiYeuCau(yeuCau.yeuCauID),
                  successMessage: 'Đã từ chối',
                  actionType: 'reject',
                ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Từ chối'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed:
                () => _performAction(
                  yeuCauId: yeuCau.yeuCauID,
                  action: () => _yeuCauRepo.xacNhanYeuCau(yeuCau.yeuCauID),
                  successMessage: 'Đã chấp nhận',
                  actionType: 'accept',
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Chấp nhận',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    return TextButton(
      onPressed: () async {
        if (_taiKhoanId != null) {
          await _performAction(
            yeuCauId: yeuCau.yeuCauID,
            action:
                () => _yeuCauRepo.huyYeuCau(
                  yeuCauId: yeuCau.yeuCauID,
                  nguoiGuiTaiKhoanId: _taiKhoanId!,
                ),
            successMessage: 'Đã hủy',
            actionType: 'cancel',
          );
        }
      },
      child: const Text('Hủy lời mời', style: TextStyle(color: Colors.red)),
    );
  }
}
