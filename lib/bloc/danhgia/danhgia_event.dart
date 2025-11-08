part of 'danhgia_bloc.dart';

abstract class DanhGiaEvent {}

/// Event tạo/cập nhật đánh giá
class TaoDanhGia extends DanhGiaEvent {
  final int giaSuId;
  final double diemSo;
  final String? binhLuan;

  TaoDanhGia({
    required this.giaSuId,
    required this.diemSo,
    this.binhLuan,
  });
}

/// Event lấy danh sách đánh giá của gia sư
class LoadDanhGiaGiaSu extends DanhGiaEvent {
  final int giaSuId;

  LoadDanhGiaGiaSu({required this.giaSuId});
}

/// Event kiểm tra đã đánh giá chưa
class KiemTraDaDanhGia extends DanhGiaEvent {
  final int giaSuId;

  KiemTraDaDanhGia({required this.giaSuId});
}

/// Event xóa đánh giá
class XoaDanhGia extends DanhGiaEvent {
  final int danhGiaId;

  XoaDanhGia({required this.danhGiaId});
}
