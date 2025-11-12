import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/yeu_cau_nhan_lop_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/untils/format_vnd.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_info_row.dart';

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
  //late final TutorRepository _giasuRepo;
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
          _errorMessage = null;
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
        _errorMessage = 'Có lỗi xảy ra: $e';
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
    String? actionType, // Thêm tham số để xác định loại action
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

        // Gửi notification khi chấp nhận proposal để tutor screen refresh
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
          response.message.isNotEmpty
              ? response.message
              : 'Thao tác không thành công, vui lòng thử lại.',
          true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _setActionProgress(yeuCauId, false);
      _showSnack('Có lỗi xảy ra: $e', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.background),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đề nghị cho lớp ${widget.lopHocId}',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: AppTypography.appBarTitle,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lỗi: $_errorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _loadProposals(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_proposals.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadProposals(showLoader: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                'Chưa có đề nghị nào cho lớp học này.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProposals(showLoader: false),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _proposals.length,
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    yeuCau.lopHoc.tieuDeLop,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Chip(
                  label: Text(yeuCau.trangThai),
                  backgroundColor:
                      yeuCau.isPending
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.person,
              label: 'Gia sư',
              value: yeuCau.giaSuHoTen ?? 'Chưa có thông tin',
            ),
            InfoRow(
              icon: Icons.attach_money,
              label: 'Học phí',
              value: formatCurrency(yeuCau.lopHoc.hocPhi),
            ),
            if (yeuCau.ghiChu?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.note,
                label: 'Ghi chú',
                value: yeuCau.ghiChu ?? 'Không có ghi chú',
              ),
            ],

            // ---------- BẠN HÃY DÁN KHỐI CODE NÚT BẤM VÀO ĐÂY ----------
            // Chỉ hiển thị nút nếu có thông tin gia sư
            if (yeuCau.giaSuID != null)
              Padding(
                // Thêm padding để nút không quá sát
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft, // Đặt nút ở bên trái
                  child: TextButton.icon(
                    icon: const Icon(Icons.person_search_outlined, size: 18),
                    label: const Text('Xem chi tiết gia sư'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // Giảm vùng bấm
                      backgroundColor: Colors.blue.withOpacity(
                        0.05,
                      ), // Thêm màu nền nhẹ
                    ),
                    onPressed: () {
                      // Điều hướng đến trang chi tiết gia sư
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TutorDetailPage(tutorId: yeuCau.giaSuID!),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // ------------------ KẾT THÚC KHỐI CODE ------------------
            const SizedBox(height: 12),
            if (isPending)
              Align(
                alignment: Alignment.centerRight,
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : _buildActionButtons(yeuCau, sentByTutor),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(YeuCauNhanLop yeuCau, bool sentByTutor) {
    if (sentByTutor) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed:
                () => _performAction(
                  yeuCauId: yeuCau.yeuCauID,
                  action: () => _yeuCauRepo.tuChoiYeuCau(yeuCau.yeuCauID),
                  successMessage: 'Đã từ chối đề nghị của gia sư.',
                  actionType: 'reject',
                ),
            child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed:
                () => _performAction(
                  yeuCauId: yeuCau.yeuCauID,
                  action: () => _yeuCauRepo.xacNhanYeuCau(yeuCau.yeuCauID),
                  successMessage: 'Đã chấp nhận đề nghị của gia sư.',
                  actionType: 'accept',
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chấp nhận'),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () async {
            if (_taiKhoanId == null) {
              _showSnack(
                'Không tìm thấy thông tin tài khoản để hủy đề nghị.',
                true,
              );
              return;
            }

            await _performAction(
              yeuCauId: yeuCau.yeuCauID,
              action:
                  () => _yeuCauRepo.huyYeuCau(
                    yeuCauId: yeuCau.yeuCauID,
                    nguoiGuiTaiKhoanId: _taiKhoanId!,
                  ),
              successMessage: 'Đã hủy lời mời gia sư.',
              actionType: 'cancel',
            );
          },
          child: const Text('Hủy', style: TextStyle(color: Colors.red)),
        ),
        const SizedBox(width: 8),
        // ElevatedButton(
        //   onPressed: () async {
        //     if (_taiKhoanId == null) {
        //       _showSnack(
        //         'Không tìm thấy thông tin tài khoản để chỉnh sửa.',
        //         true,
        //       );
        //       return;
        //     }

        //     final note = await _promptUpdateNote(initial: yeuCau.ghiChu ?? '');
        //     if (note == null) {
        //       return;
        //     }

        //     await _performAction(
        //       yeuCauId: yeuCau.yeuCauID,
        //       action:
        //           () => _yeuCauRepo.capNhatYeuCau(
        //             yeuCauId: yeuCau.yeuCauID,
        //             nguoiGuiTaiKhoanId: _taiKhoanId!,
        //             ghiChu: note.isEmpty ? null : note,
        //           ),
        //       successMessage: 'Đã cập nhật ghi chú đề nghị.',
        //       actionType: 'update',
        //     );
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.blueGrey,
        //     foregroundColor: Colors.white,
        //   ),
        //   child: const Text('Chỉnh sửa'),
        // ),
      ],
    );
  }

  // Future<String?> _promptUpdateNote({required String initial}) async {
  //   final controller = TextEditingController(text: initial);
  //   final formKey = GlobalKey<FormState>();

  //   final result = await showDialog<String>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Chỉnh sửa ghi chú'),
  //         content: Form(
  //           key: formKey,
  //           child: TextFormField(
  //             controller: controller,
  //             maxLines: 4,
  //             maxLength: 500,
  //             decoration: const InputDecoration(
  //               hintText: 'Nhập ghi chú mới (không bắt buộc)',
  //               border: OutlineInputBorder(),
  //             ),
  //             validator: (value) {
  //               if ((value ?? '').length > 500) {
  //                 return 'Ghi chú tối đa 500 ký tự';
  //               }
  //               return null;
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Hủy'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (formKey.currentState?.validate() ?? false) {
  //                 Navigator.pop(context, controller.text.trim());
  //               }
  //             },
  //             child: const Text('Lưu'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   controller.dispose();
  //   return result;
  // }

  void _showSnack(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
  }
}
