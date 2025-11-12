import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/danhgia/danhgia_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/danhgia_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu_model.dart';

class DanhGiaListScreen extends StatefulWidget {
  final Tutor tutor;

  const DanhGiaListScreen({super.key, required this.tutor});

  @override
  State<DanhGiaListScreen> createState() => _DanhGiaListScreenState();
}

class _DanhGiaListScreenState extends State<DanhGiaListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DanhGiaBloc>().add(
      LoadDanhGiaGiaSu(giaSuId: widget.tutor.giaSuID),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đánh giá của học viên',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DanhGiaBloc, DanhGiaState>(
        builder: (context, state) {
          if (state is DanhGiaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DanhGiaListLoaded) {
            return _buildContent(state.response);
          }

          if (state is DanhGiaError) {
            return _buildError(state.message);
          }

          return const Center(child: Text('Đang tải...'));
        },
      ),
    );
  }

  Widget _buildContent(DanhGiaResponse response) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DanhGiaBloc>().add(
          LoadDanhGiaGiaSu(giaSuId: widget.tutor.giaSuID),
        );
      },
      child: Column(
        children: [
          // Tổng quan đánh giá
          _buildRatingSummary(response),
          
          const Divider(height: 1),

          // Danh sách đánh giá
          Expanded(
            child: response.danhGiaList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: response.danhGiaList.length,
                    separatorBuilder: (context, index) => 
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildDanhGiaCard(response.danhGiaList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(DanhGiaResponse response) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          // Điểm trung bình
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Số điểm lớn
              Column(
                children: [
                  Text(
                    response.diemTrungBinh.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < response.diemTrungBinh.floor()
                            ? Icons.star
                            : (index < response.diemTrungBinh
                                ? Icons.star_half
                                : Icons.star_border),
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${response.tongSoDanhGia} đánh giá',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 32),

              // Phân bố sao
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = response.phanBoSao[star] ?? 0;
                    final percentage = response.tongSoDanhGia > 0
                        ? (count / response.tongSoDanhGia * 100)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text('$star'),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.amber,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDanhGiaCard(DanhGia danhGia) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: danhGia.anhDaiDien != null
                      ? NetworkImage(danhGia.anhDaiDien!)
                      : null,
                  child: danhGia.anhDaiDien == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        danhGia.tenNguoiHoc ?? 'Học viên',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatDate(danhGia.ngayDanhGia),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Số sao
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < danhGia.diemSo
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),

            // Bình luận
            if (danhGia.binhLuan != null && danhGia.binhLuan!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                danhGia.binhLuan!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có đánh giá nào',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DanhGiaBloc>().add(
                LoadDanhGiaGiaSu(giaSuId: widget.tutor.giaSuID),
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}
