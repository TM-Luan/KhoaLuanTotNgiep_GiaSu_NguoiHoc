import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';

class TutorDetailPage extends StatefulWidget {
  static const String routeName = '/tutor-detail';
  
  final Tutor? tutor; // Nhận từ arguments
  final int? tutorId; // Hoặc nhận ID để fetch từ API

  const TutorDetailPage({
    super.key,
    this.tutor,
    this.tutorId,
  });

  @override
  State<TutorDetailPage> createState() => _TutorDetailPageState();
}

class _TutorDetailPageState extends State<TutorDetailPage> {
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
                    image: tutor.image.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(tutor.image),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: tutor.image.isEmpty
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Thông tin chi tiết
          _buildInfoSection('Thông tin liên hệ', [
            _buildInfoItem('Email', tutor.taiKhoan.email, Icons.email),
            _buildInfoItem('Số điện thoại', tutor.taiKhoan.soDienThoai, Icons.phone),
          ]),

          if (tutor.diaChi != null) ...[
            const SizedBox(height: 24),
            _buildInfoSection('Thông tin cá nhân', [
              if (tutor.diaChi != null)
                _buildInfoItem('Địa chỉ', tutor.diaChi!, Icons.location_on),
              if (tutor.gioiTinh != null)
                _buildInfoItem('Giới tính', tutor.gioiTinh!, Icons.person),
              if (tutor.ngaySinh != null)
                _buildInfoItem('Ngày sinh', _formatDate(tutor.ngaySinh!), Icons.cake),
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
                      // TODO: Implement contact functionality
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
                    onPressed: () {
                      // TODO: Implement offer teaching functionality
                      _showOfferDialog(tutor);
                    },
                    icon: const Icon(Icons.school),
                    label: const Text('Đề nghị dạy'),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
                        color: index < rating.floor()
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
      builder: (context) => AlertDialog(
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
              // TODO: Implement call/email functionality
              Navigator.pop(context);
            },
            child: const Text('Gọi ngay'),
          ),
        ],
      ),
    );
  }

  void _showOfferDialog(Tutor tutor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đề nghị dạy'),
        content: const Text('Bạn muốn gửi đề nghị dạy đến gia sư này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement offer teaching functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi đề nghị dạy thành công!'),
                ),
              );
            },
            child: const Text('Gửi đề nghị'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nhận tutor từ arguments nếu có
    final Tutor? tutorFromArgs = ModalRoute.of(context)?.settings.arguments as Tutor?;
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
      appBar: AppBar(
        title: const Text('Chi tiết gia sư'),
      ),
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
                        context.read<TutorBloc>().add(LoadTutorByIdEvent(widget.tutorId!));
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