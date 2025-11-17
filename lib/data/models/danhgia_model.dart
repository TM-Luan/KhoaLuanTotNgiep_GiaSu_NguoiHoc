// file: danhgia_model.dart (ĐÃ SỬA LỖI)

class DanhGia {
  final int danhGiaID;
  final int lopYeuCauID;
  final int taiKhoanID;
  final double diemSo;
  final String? binhLuan;
  final String ngayDanhGia;
  final String? tenNguoiHoc;
  final String? anhDaiDien;

  DanhGia({
    required this.danhGiaID,
    required this.lopYeuCauID,
    required this.taiKhoanID,
    required this.diemSo,
    this.binhLuan,
    required this.ngayDanhGia,
    this.tenNguoiHoc,
    this.anhDaiDien,
  });

  factory DanhGia.fromJson(Map<String, dynamic> json) {
    return DanhGia(
      danhGiaID: json['DanhGiaID'] ?? 0,
      lopYeuCauID: json['LopYeuCauID'] ?? 0,
      taiKhoanID: json['TaiKhoanID'] ?? 0,
      diemSo: (json['DiemSo'] as num?)?.toDouble() ?? 0.0,
      binhLuan: json['BinhLuan'],
      ngayDanhGia: json['NgayDanhGia'] ?? '',
      tenNguoiHoc:
          json['tai_khoan']?['Email'] ?? json['lop']?['nguoi_hoc']?['HoTen'],
      anhDaiDien: json['lop']?['nguoi_hoc']?['AnhDaiDien'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DanhGiaID': danhGiaID,
      'LopYeuCauID': lopYeuCauID,
      'TaiKhoanID': taiKhoanID,
      'DiemSo': diemSo,
      'BinhLuan': binhLuan,
      'NgayDanhGia': ngayDanhGia,
    };
  }
}

class DanhGiaResponse {
  final List<DanhGia> danhGiaList;
  final double diemTrungBinh;
  final int tongSoDanhGia;
  final Map<int, int> phanBoSao;

  DanhGiaResponse({
    required this.danhGiaList,
    required this.diemTrungBinh,
    required this.tongSoDanhGia,
    required this.phanBoSao,
  });

  factory DanhGiaResponse.fromJson(Map<String, dynamic> json) {
    // SỬA: Bỏ "final data = json['data'];" và dùng trực tiếp "json"
    return DanhGiaResponse(
      danhGiaList:
          (json['danh_gia_list'] as List?)
              ?.map((item) => DanhGia.fromJson(item))
              .toList() ??
          [],
      diemTrungBinh: (json['diem_trung_binh'] as num?)?.toDouble() ?? 0.0,
      tongSoDanhGia: json['tong_so_danh_gia'] ?? 0,
      phanBoSao:
          (json['phan_bo_sao'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(int.parse(key), value as int),
          ) ??
          {},
    );
  }
}

class KiemTraDanhGiaResponse {
  final bool coTheDanhGia;
  final bool daDanhGia;
  final bool daSua;
  final DanhGia? danhGia;
  final int? lopHocId;
  final String? message;

  KiemTraDanhGiaResponse({
    required this.coTheDanhGia,
    required this.daDanhGia,
    required this.daSua,
    this.danhGia,
    this.lopHocId,
    this.message,
  });

  factory KiemTraDanhGiaResponse.fromJson(Map<String, dynamic> json) {
    // SỬA: Bỏ "final data = json['data'];" và dùng trực tiếp "json"
    return KiemTraDanhGiaResponse(
      coTheDanhGia: json['co_the_danh_gia'] ?? false,
      daDanhGia: json['da_danh_gia'] ?? false,
      daSua: json['da_sua'] ?? false,
      danhGia:
          json['danh_gia'] != null ? DanhGia.fromJson(json['danh_gia']) : null,
      lopHocId: json['lop_hoc_id'],
      message: json['message'],
    );
  }
}
