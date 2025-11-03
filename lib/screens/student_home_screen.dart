import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/tutor_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/app_components.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';

class LearnerHomeScreen extends StatefulWidget {
  final UserProfile? userProfile;

  const LearnerHomeScreen({super.key, this.userProfile});

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  UserProfile? currentProfile;
  final LopHocRepository _lopHocRepository = LopHocRepository();
  bool _isProcessingInvite = false;

  @override
  void initState() {
    super.initState();
    currentProfile = widget.userProfile;
    context.read<TutorBloc>().add(LoadAllTutorsEvent());
  }

  String get displayName {
    return currentProfile?.hoTen ?? 'Người dùng';
  }

  String get avatarText {
    final userName = currentProfile?.hoTen ?? '';
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

  Widget _buildTutorList(BuildContext context, TutorState state) {
    if (state is TutorLoadingState) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is TutorErrorState) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: ${state.message}', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.read<TutorBloc>().add(LoadAllTutorsEvent());
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AllTutorsLoadedState) {
      final tutorList = state.tutors;

      if (tutorList.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: Text('Không có gia sư nào.')),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.crossAxisExtent >= 420 ? 3 : 2;

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final tutor = tutorList[index];
                return TutorCard(
                  tutor: tutor,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      TutorDetailPage.routeName,
                      arguments: tutor,
                    );
                  },
                  onOfferTap: _isProcessingInvite ? null : () => _handleOfferTap(tutor),
                );
              }, childCount: tutorList.length),
            );
          },
        ),
      );
    }

    return const SliverFillRemaining(
      child: Center(child: Text('Vui lòng tải danh sách gia sư')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: StandardAppBar(
        leadingIcon: Icons.person_search,
        title: 'Xin chào, $displayName',
        subtitle: 'Tìm kiếm gia sư phù hợp',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SearchBarCustom(onFilter: () {}),
            ),
            
            // Title section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppIconContainer(
                        icon: Icons.people,
                        backgroundColor: AppColors.primaryContainer,
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Text(
                        'DANH SÁCH GIA SƯ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppTypography.body2,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.blue.shade50,
                    ),
                    child: IconButton(
                      onPressed: () {
                        context.read<TutorBloc>().add(RefreshTutorsEvent());
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      tooltip: 'Làm mới danh sách',
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: CustomScrollView(
                slivers: [
                  BlocBuilder<TutorBloc, TutorState>(
                    builder: (context, state) {
                      return _buildTutorList(context, state);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method để xử lý khi user ấn nút "Đề nghị dạy"
  void _handleOfferTap(Tutor tutor) {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is! AuthAuthenticated ||
        authState.user.nguoiHocID == null ||
        authState.user.taiKhoanID == null) {
      _showSnack(
        'Vui lòng đăng nhập bằng tài khoản người học để gửi đề nghị.',
        true,
      );
      return;
    }

    _loadClassesAndPrompt(authState, tutor);
  }

  Future<void> _loadClassesAndPrompt(AuthAuthenticated auth, Tutor tutor) async {
    setState(() {
      _isProcessingInvite = true;
    });

    final ApiResponse<List<LopHoc>> response =
        await _lopHocRepository.getLopHocCuaNguoiHoc();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingInvite = false;
    });

    if (!response.isSuccess || response.data == null) {
      _showSnack(
        response.message.isNotEmpty
            ? response.message
            : 'Không thể lấy danh sách lớp của bạn.',
        true,
      );
      return;
    }

    final availableClasses = response.data!
        .where((lop) {
          final status = (lop.trangThai ?? '').toUpperCase();
          return status == 'TIMGIASU' || status == 'CHODUYET';
        })
        .toList();

    if (availableClasses.isEmpty) {
      _showSnack('Bạn chưa có lớp nào đang tìm gia sư để gửi đề nghị.', true);
      return;
    }

    int selectedClassId = availableClasses.first.maLop;
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gửi đề nghị tới gia sư ${tutor.hoTen}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Chọn lớp học:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedClassId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedClassId = value;
                        });
                      }
                    },
                    items: availableClasses.map((lop) {
                      return DropdownMenuItem<int>(
                        value: lop.maLop,
                        child: Text(
                          lop.tieuDeLop,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ghi chú (tùy chọn):'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: noteController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Thêm ghi chú cho đề nghị...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'classId': selectedClassId,
                            'note': noteController.text.trim(),
                          });
                        },
                        child: const Text('Gửi đề nghị'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      await _sendInvite(
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
    required String ghiChu,
    required AuthAuthenticated auth,
  }) async {
    setState(() {
      _isProcessingInvite = true;
    });

    final repo = context.read<YeuCauNhanLopRepository>();
    final response = await repo.nguoiHocMoiGiaSu(
      lopId: lopId,
      giaSuId: tutor.giaSuID,
      nguoiGuiTaiKhoanId: auth.user.taiKhoanID!,
      ghiChu: ghiChu.isEmpty ? null : ghiChu,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingInvite = false;
    });

    if (response.isSuccess) {
      _showSnack('Đã gửi đề nghị tới gia sư.', false);
    } else {
      _showSnack(
        response.message.isNotEmpty
            ? response.message
            : 'Không thể gửi đề nghị, vui lòng thử lại.',
        true,
      );
    }
  }

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
