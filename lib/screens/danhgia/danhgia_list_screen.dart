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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đánh giá & Nhận xét',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
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
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildRatingSummary(response)),
          SliverToBoxAdapter(
            child: Divider(height: 1, thickness: 8, color: Colors.grey.shade50),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver:
                response.danhGiaList.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildDanhGiaItem(response.danhGiaList[index]);
                      }, childCount: response.danhGiaList.length),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(DanhGiaResponse response) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cột điểm số lớn bên trái
          Column(
            children: [
              Text(
                response.diemTrungBinh.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -2,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < response.diemTrungBinh.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                '${response.tongSoDanhGia} nhận xét',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Cột thanh tiến trình bên phải
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = response.phanBoSao[star] ?? 0;
                final percentage =
                    response.tongSoDanhGia > 0
                        ? (count / response.tongSoDanhGia)
                        : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                        child: Text(
                          '$star',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildDanhGiaItem(DanhGia danhGia) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image:
                      danhGia.anhDaiDien != null
                          ? DecorationImage(
                            image: NetworkImage(danhGia.anhDaiDien!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    danhGia.anhDaiDien == null
                        ? Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade400,
                        )
                        : null,
              ),
              const SizedBox(width: 12),

              // Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      danhGia.tenNguoiHoc ?? 'Người dùng ẩn danh',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(danhGia.ngayDanhGia),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              // Stars
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Text(
                      danhGia.diemSo.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (danhGia.binhLuan != null && danhGia.binhLuan!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              danhGia.binhLuan!,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có đánh giá nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed:
                  () => context.read<DanhGiaBloc>().add(
                    LoadDanhGiaGiaSu(giaSuId: widget.tutor.giaSuID),
                  ),
              child: const Text("Thử lại"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }
}
