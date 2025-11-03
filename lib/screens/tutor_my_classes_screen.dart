import 'dart:async';
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
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_class_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/services/global_notification_service.dart';

class TutorMyClassesScreen extends StatefulWidget {
  const TutorMyClassesScreen({Key? key}) : super(key: key);

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
    
    // Lắng nghe notification về proposal updates
    _proposalUpdateSubscription = GlobalNotificationService()
        .proposalUpdateStream
        .listen((event) {
      // Refresh data khi có proposal được chấp nhận/từ chối
      if (_currentBloc != null) {
        print('🔔 Nhận notification proposal update: ${event.type}, classId: ${event.classId}');
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
          child: Text('Vui lòng đăng nhập bằng tài khoản gia sư để xem dữ liệu.'),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lớp của tôi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            elevation: 0,
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa có lớp học nào đang dạy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
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
                  colors: [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
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
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lop.tieuDeLop,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.person, 'Học viên', lop.tenNguoiHoc),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.attach_money, 'Học phí', lop.hocPhi),
                    if (lop.diaChi?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Địa chỉ', lop.diaChi!),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Nút xem chi tiết cho lớp đang dạy
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToClassDetail(context, lop.maLop),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Xem chi tiết'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 0,
                          ),
                        ),
                      ),
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
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
    
    // Xác định màu sắc và icon dựa trên loại đề nghị
    Color cardColor = isSentByTutor ? Colors.blue.shade50 : Colors.orange.shade50;
    Color statusColor = isSentByTutor ? Colors.blue.shade100 : Colors.orange.shade100;
    IconData statusIcon = isSentByTutor ? Icons.send_outlined : Icons.mail_outline;

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
            colors: [
              cardColor,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với icon và tiêu đề
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      statusIcon,
                      color: isSentByTutor ? Colors.blue.shade700 : Colors.orange.shade700,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      yeuCau.lopHoc.tieuDeLop,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
              
              // Thông tin chi tiết tóm gọn
              Row(
                children: [
                  Expanded(
                    child: _buildCompactInfo(Icons.person, yeuCau.lopHoc.tenNguoiHoc),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactInfo(Icons.attach_money, yeuCau.lopHoc.hocPhi),
                  ),
                ],
              ),
              
              if (yeuCau.ghiChu?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          yeuCau.ghiChu!.length > 50 
                              ? '${yeuCau.ghiChu!.substring(0, 50)}...'
                              : yeuCau.ghiChu!,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Phần trạng thái và nút action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isSentByTutor ? '📤 Bạn đã gửi' : '📨 Mời bạn',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: isSentByTutor ? Colors.blue.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isActionLoading)
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    _buildActionButtons(context, yeuCau),
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
    
    // Lấy taiKhoanId của user hiện tại để kiểm tra quyền
    final authState = context.read<AuthBloc>().state;
    int currentTaiKhoanId = 0;
    if (authState is AuthAuthenticated) {
      currentTaiKhoanId = authState.user.taiKhoanID ?? 0;
    }
    
    // Kiểm tra xem đề nghị có phải do user hiện tại tạo không
    final bool isOwnRequest = yeuCau.nguoiGuiTaiKhoanID == currentTaiKhoanId;

    if (isSentByTutor) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút chi tiết nhỏ gọn
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: InkWell(
              onTap: () => _navigateToClassDetail(context, yeuCau.lopYeuCauID),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Chi tiết',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOwnRequest) ...[
            const SizedBox(width: 6),
            // Nút sửa nhỏ gọn
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: InkWell(
                onTap: () => _showUpdateNoteDialog(context, yeuCau),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Sửa',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Nút hủy nhỏ gọn
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: InkWell(
                onTap: () => bloc.add(TutorClassRequestCancelled(yeuCau.yeuCauID)),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cancel, size: 14, color: Colors.red.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Nếu không phải đề nghị của user hiện tại, hiển thị thông báo
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Đề nghị từ session khác',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nút chi tiết nhỏ gọn
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: InkWell(
            onTap: () => _navigateToClassDetail(context, yeuCau.lopYeuCauID),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Nút từ chối nhỏ gọn
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: InkWell(
            onTap: () => bloc.add(TutorClassRequestRejected(yeuCau.yeuCauID)),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Từ chối',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Nút xác nhận nhỏ gọn
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
          ),
          child: InkWell(
            onTap: () => bloc.add(TutorClassRequestConfirmed(yeuCau.yeuCauID)),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text(
                    'Chấp nhận',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // Widget thông tin thu gọn để tiết kiệm không gian
  Widget _buildCompactInfo(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to class detail page
  void _navigateToClassDetail(BuildContext context, int lopHocId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorClassDetailPage(lopHocId: lopHocId),
      ),
    );
  }
}
