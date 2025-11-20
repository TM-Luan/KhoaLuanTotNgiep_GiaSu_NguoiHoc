import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/danhgia/danhgia_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/danhgia/danhgia_dialog.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/danhgia/danhgia_list_screen.dart';

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
          // 1. Header: Avatar, Tên, Bằng cấp
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
                    border: Border.all(color: Colors.blue.shade100, width: 4),
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tutor.bangCap ?? 'Gia sư',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 2. Thông tin Liên hệ
          _buildInfoSection('Thông tin liên hệ', [
            _buildInfoItem('Email', tutor.taiKhoan.email, Icons.email),
            _buildInfoItem(
              'Số điện thoại',
              tutor.taiKhoan.soDienThoai,
              Icons.phone,
            ),
          ]),

          // 3. Thông tin Học vấn & Chuyên môn (MỚI)
          const SizedBox(height: 24),
          _buildInfoSection('Học vấn & Chuyên môn', [
            if (tutor.truongDaoTao != null && tutor.truongDaoTao!.isNotEmpty)
              _buildInfoItem(
                'Trường đào tạo',
                tutor.truongDaoTao!,
                Icons.school,
              ),
            if (tutor.chuyenNganh != null && tutor.chuyenNganh!.isNotEmpty)
              _buildInfoItem('Chuyên ngành', tutor.chuyenNganh!, Icons.book),
            if (tutor.kinhNghiem != null && tutor.kinhNghiem!.isNotEmpty)
              _buildInfoItem(
                'Kinh nghiệm',
                tutor.kinhNghiem!,
                Icons.work_history,
              ),
          ]),

          // 4. Thành tích nổi bật (MỚI)
          if (tutor.thanhTich != null && tutor.thanhTich!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildInfoSection('Thành tích nổi bật', [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tutor.thanhTich!,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],

          // 5. Thông tin Cá nhân
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

          // 6. Đánh giá
          const SizedBox(height: 24),
          _buildInfoSection('Đánh giá từ học viên', [
            _buildRatingItem('Điểm đánh giá', tutor.rating),
          ]),

          const SizedBox(height: 32),

          // 7. Nút hành động (Giữ nguyên logic cũ)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Mời dạy'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DanhGiaListScreen(tutor: tutor),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rate_review),
                        label: Text('Xem đánh giá (${tutor.tongSoDanhGia})'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRatingDialog(tutor),
                        icon: const Icon(Icons.star_rate),
                        label: const Text('Đánh giá'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
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

  // void _showContactDialog(Tutor tutor) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Liên hệ gia sư'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text('Gia sư: ${tutor.name}'),
  //               const SizedBox(height: 8),
  //               Text('Email: ${tutor.taiKhoan.email}'),
  //               Text('SĐT: ${tutor.taiKhoan.soDienThoai}'),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Đóng'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: const Text('Gọi ngay'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

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

  Future<void> _loadClassesAndPrompt(
    AuthAuthenticated auth,
    Tutor tutor,
  ) async {
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

    final availableClasses =
        response.data!.where((lop) {
          final status = (lop.trangThai ?? '').toUpperCase();
          return status == 'TIMGIASU' || status == 'CHODUYET';
        }).toList();

    if (availableClasses.isEmpty) {
      _showSnack('Bạn chưa có lớp nào đang tìm gia sư để mời gia sư.', true);
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
                  // Header với icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gửi lời mời dạy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Gia sư: ${tutor.name}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Chọn lớp học
                  Text(
                    'Chọn lớp học',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: selectedClassId,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        prefixIcon: Icon(Icons.class_, size: 20),
                      ),
                      items:
                          availableClasses.map((lop) {
                            final title =
                                lop.tieuDeLop.trim().isEmpty
                                    ? 'Chưa đặt tên'
                                    : lop.tieuDeLop;
                            return DropdownMenuItem<int>(
                              value: lop.maLop,
                              child: Text(
                                '${lop.maLop} - $title',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedClassId = value;
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ghi chú
                  Text(
                    'Ghi chú (tùy chọn)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: noteController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Mô tả yêu cầu, thời gian mong muốn, hoặc câu hỏi cho gia sư...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        counterStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context, {
                              'lopId': selectedClassId,
                              'note': noteController.text.trim(),
                            });
                          },
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text(
                            'Gửi lời mời dạy',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
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

    await _sendInvite(tutor: tutor, lopId: lopId, ghiChu: note, auth: auth);
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
      _showSnack('Đã gửi lời mời dạy tới gia sư.', false);
    } else {
      _showSnack(
        response.message.isNotEmpty
            ? response.message
            : 'Không thể gửi lời mời dạy, vui lòng thử lại.',
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

  void _showRatingDialog(Tutor tutor) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated || authState.user.nguoiHocID == null) {
      _showSnack(
        'Vui lòng đăng nhập bằng tài khoản người học để đánh giá',
        true,
      );
      return;
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Kiểm tra xem học viên có được phép đánh giá không
    context.read<DanhGiaBloc>().add(KiemTraDaDanhGia(giaSuId: tutor.giaSuID));

    // Đợi kết quả kiểm tra
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final danhGiaBloc = context.read<DanhGiaBloc>();
    final state = danhGiaBloc.state;

    // Đóng loading dialog
    Navigator.pop(context);

    if (state is DanhGiaError) {
      _showSnack(state.message, true);
      return;
    }

    if (state is! KiemTraDanhGiaLoaded) {
      _showSnack('Không thể kiểm tra quyền đánh giá', true);
      return;
    }

    final checkResult = state.response;

    // Kiểm tra có thể đánh giá không
    if (!checkResult.coTheDanhGia) {
      _showSnack(checkResult.message ?? 'Bạn chưa học với gia sư này', true);
      return;
    }

    // Nếu đã đánh giá rồi, hiển thị cảnh báo
    if (checkResult.daDanhGia && checkResult.danhGia != null) {
      final danhGiaCu = checkResult.danhGia!;

      // Nếu đã sửa rồi, không cho sửa nữa
      if (checkResult.daSua) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.block,
                        color: Colors.red[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Không thể chỉnh sửa',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đánh giá hiện tại:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                danhGiaCu.diemSo.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ],
                          ),
                          if (danhGiaCu.binhLuan != null &&
                              danhGiaCu.binhLuan!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              danhGiaCu.binhLuan!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Bạn đã chỉnh sửa đánh giá này rồi. Mỗi học viên chỉ được sửa đánh giá 1 lần duy nhất và không thể thay đổi nữa.',
                              style: TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
        );
        return;
      }

      // Nếu chưa sửa, cho phép sửa 1 lần
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chỉnh sửa đánh giá',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đánh giá hiện tại:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              danhGiaCu.diemSo.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ],
                        ),
                        if (danhGiaCu.binhLuan != null &&
                            danhGiaCu.binhLuan!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            danhGiaCu.binhLuan!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'LƯU Ý: Bạn chỉ có thể chỉnh sửa đánh giá này 1 LẦN DUY NHẤT. Sau khi sửa, bạn sẽ không thể thay đổi nữa.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Tôi hiểu, tiếp tục sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
      );

      if (confirmed != true) return;
    }

    // Hiện dialog đánh giá với dữ liệu cũ (nếu có)
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => DanhGiaGiaSuDialog(
            tutor: tutor,
            initialRating: checkResult.danhGia?.diemSo.toDouble(),
            initialComment: checkResult.danhGia?.binhLuan,
          ),
    );

    // Reload dữ liệu nếu đánh giá thành công
    if (result == true && mounted) {
      // Reload tutor detail
      context.read<TutorBloc>().add(LoadTutorByIdEvent(tutor.giaSuID));

      // Reload toàn bộ danh sách gia sư
      context.read<TutorBloc>().add(LoadAllTutorsEvent());

      _showSnack('Cảm ơn bạn đã đánh giá!', false);

      // Quay về trang trước sau 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
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
