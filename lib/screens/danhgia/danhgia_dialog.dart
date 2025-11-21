import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/danhgia/danhgia_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu_model.dart';

class DanhGiaGiaSuDialog extends StatefulWidget {
  final Tutor tutor;
  final double? initialRating;
  final String? initialComment;

  const DanhGiaGiaSuDialog({
    super.key,
    required this.tutor,
    this.initialRating,
    this.initialComment,
  });

  @override
  State<DanhGiaGiaSuDialog> createState() => _DanhGiaGiaSuDialogState();
}

class _DanhGiaGiaSuDialogState extends State<DanhGiaGiaSuDialog> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _commentController.text = widget.initialComment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chạm vào sao để chấm điểm'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<DanhGiaBloc>().add(
      TaoDanhGia(
        giaSuId: widget.tutor.giaSuID,
        diemSo: _rating,
        binhLuan:
            _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DanhGiaBloc, DanhGiaState>(
      listener: (context, state) {
        if (state is DanhGiaSuccess) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is DanhGiaError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Tutor Info Minimal ---
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage:
                          (widget.tutor.anhDaiDien != null &&
                                  widget.tutor.anhDaiDien!.isNotEmpty)
                              ? NetworkImage(widget.tutor.anhDaiDien!)
                              : null,
                      child:
                          (widget.tutor.anhDaiDien == null ||
                                  widget.tutor.anhDaiDien!.isEmpty)
                              ? Icon(Icons.person, color: Colors.grey.shade400)
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Đánh giá ${widget.tutor.hoTen}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // if (widget.tutor.tenMon != null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 4),
                    //     child: Text(
                    //       widget.tutor.tenMon!,
                    //       style: TextStyle(
                    //         fontSize: 13,
                    //         color: Colors.grey.shade500,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- Stars ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap:
                          _isSubmitting
                              ? null
                              : () => setState(
                                () => _rating = (index + 1).toDouble(),
                              ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedScale(
                          scale: (index < _rating) ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            index < _rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 36,
                            color:
                                index < _rating
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 8),
                Text(
                  _rating > 0 ? _getRatingText(_rating) : "Chạm để đánh giá",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        _rating > 0
                            ? Colors.amber.shade800
                            : Colors.grey.shade400,
                  ),
                ),

                const SizedBox(height: 32),

                // --- Comment Field Modern ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _commentController,
                    enabled: !_isSubmitting,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm học tập của bạn...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                      counterText: "", // Ẩn bộ đếm ký tự mặc định cho gọn
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- Buttons ---
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Để sau",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  widget.initialRating != null
                                      ? 'Cập nhật'
                                      : 'Gửi ngay',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Tuyệt vời!';
    if (rating >= 4) return 'Rất hài lòng';
    if (rating >= 3) return 'Hài lòng';
    if (rating >= 2) return 'Tạm được';
    return 'Không hài lòng';
  }
}
