import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';

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

    // Nếu chỉ có tutorId, fetch chi tiết từ API
    if (widget.tutorId != null && widget.tutor == null) {
      context.read<TutorBloc>().add(LoadTutorByIdEvent(widget.tutorId!));
    }
  }

  Widget _buildTutorDetail(Tutor tutor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar và thông tin cơ bản
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[100],
                    image:
                        tutor.image.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(tutor.image),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      tutor.image.isEmpty
                          ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue,
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  tutor.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (tutor.bangCap != null)
                  Text(
                    tutor.bangCap!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Thông tin chi tiết
          _buildInfoSection('Thông tin liên hệ', [
            _buildInfoItem('Email', tutor.taiKhoan.email, Icons.email),
            _buildInfoItem(
              'Số điện thoại',
              tutor.taiKhoan.soDienThoai,
              Icons.phone,
            ),
          ]),

          if (tutor.diaChi != null) ...[
            const SizedBox(height: 24),
            _buildInfoSection('Thông tin cá nhân', [
              if (tutor.diaChi != null)
                _buildInfoItem('Địa chỉ', tutor.diaChi!, Icons.location_on),
              if (tutor.gioiTinh != null)
                _buildInfoItem('Giới tính', tutor.gioiTinh!, Icons.person),
              if (tutor.ngaySinh != null)
                _buildInfoItem(
                  'Ngày sinh',
                  _formatDate(tutor.ngaySinh!),
                  Icons.cake,
                ),
            ]),
          ],

          if (tutor.kinhNghiem != null) ...[
            const SizedBox(height: 24),
            _buildInfoSection('Kinh nghiệm & Đánh giá', [
              _buildInfoItem('Kinh nghiệm', tutor.kinhNghiem!, Icons.work),
              _buildRatingItem('Điểm đánh giá', tutor.rating),
            ]),
          ],

          const SizedBox(height: 32),

          // Nút hành động
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showContactDialog(tutor);
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Liên hệ ngay'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isProcessingInvite
                            ? null
                            : () => _showOfferDialog(tutor),
                    icon:
                        _isProcessingInvite
                            ? const SizedBox.shrink()
                            : const Icon(Icons.school),
                    label:
                        _isProcessingInvite
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Đề nghị dạy'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildRatingItem(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, size: 20, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color:
                            index < rating.floor()
                                ? Colors.amber
                                : Colors.grey[300],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showContactDialog(Tutor tutor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Liên hệ gia sư'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gia sư: ${tutor.name}'),
                const SizedBox(height: 8),
                Text('Email: ${tutor.taiKhoan.email}'),
                Text('SĐT: ${tutor.taiKhoan.soDienThoai}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Gọi ngay'),
              ),
            ],
          ),
    );
  }

  void _showOfferDialog(Tutor tutor) {
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
                  const Text(
                    'Chọn lớp để mời gia sư',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedClassId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Lớp học',
                    ),
                    items: availableClasses
                        .map((lop) {
                          final title =
                              lop.tieuDeLop.trim().isEmpty
                                  ? 'Chưa đặt tên'
                                  : lop.tieuDeLop;
                          return DropdownMenuItem<int>(
                            value: lop.maLop,
                            child: Text('${lop.maLop} - $title'),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedClassId = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Ghi chú cho gia sư (không bắt buộc)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                            'lopId': selectedClassId,
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

    noteController.dispose();

    if (result == null) {
      return;
    }

    final lopId = result['lopId'] as int?;
    final note = (result['note'] as String?) ?? '';

    if (lopId == null) {
      _showSnack('Vui lòng chọn lớp học hợp lệ.', true);
      return;
    }

    await _sendInvite(
      tutor: tutor,
      lopId: lopId,
      ghiChu: note,
      auth: auth,
    );
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

  @override
  Widget build(BuildContext context) {
    // Nhận tutor từ arguments nếu có
    final Tutor? tutorFromArgs =
        ModalRoute.of(context)?.settings.arguments as Tutor?;
    final Tutor? tutor = widget.tutor ?? tutorFromArgs;

    // Nếu đã có tutor data, hiển thị ngay
    if (tutor != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết gia sư'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<TutorBloc>().add(RefreshTutorsEvent());
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _buildTutorDetail(tutor),
      );
    }

    // Nếu chưa có data, sử dụng BLoC để fetch
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết gia sư')),
      body: BlocBuilder<TutorBloc, TutorState>(
        builder: (context, state) {
          if (state is TutorLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TutorDetailLoadedState) {
            return _buildTutorDetail(state.tutor);
          } else if (state is TutorErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.tutorId != null) {
                        context.read<TutorBloc>().add(
                          LoadTutorByIdEvent(widget.tutorId!),
                        );
                      }
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Đang tải thông tin...'));
        },
      ),
    );
  }
}
