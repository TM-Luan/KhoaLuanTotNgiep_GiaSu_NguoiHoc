part of 'danhgia_bloc.dart';

abstract class DanhGiaState {}

class DanhGiaInitial extends DanhGiaState {}

class DanhGiaLoading extends DanhGiaState {}

/// State khi load danh sách đánh giá thành công
class DanhGiaListLoaded extends DanhGiaState {
  final DanhGiaResponse response;

  DanhGiaListLoaded(this.response);
}

/// State khi kiểm tra đã đánh giá thành công
class KiemTraDanhGiaLoaded extends DanhGiaState {
  final KiemTraDanhGiaResponse response;

  KiemTraDanhGiaLoaded(this.response);
}

/// State khi tạo/cập nhật đánh giá thành công
class DanhGiaSuccess extends DanhGiaState {
  final String message;
  final DanhGia danhGia;

  DanhGiaSuccess(this.message, this.danhGia);
}

/// State khi xóa đánh giá thành công
class DanhGiaDeleted extends DanhGiaState {
  final String message;

  DanhGiaDeleted(this.message);
}

/// State khi có lỗi
class DanhGiaError extends DanhGiaState {
  final String message;

  DanhGiaError(this.message);
}
