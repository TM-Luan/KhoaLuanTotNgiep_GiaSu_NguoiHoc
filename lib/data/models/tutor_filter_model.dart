class TutorFilter {
  final String? chuyenMon;
  final String? khuVuc;
  final String? gioiTinh;
  final String? bangCap;
  final String? kinhNghiem; // Thay đổi từ min/max thành single value
  final String? minRating; // NEW: Lọc theo đánh giá tối thiểu
  final String? maxRating; // NEW: Lọc theo đánh giá tối đa

  TutorFilter({
    this.chuyenMon,
    this.khuVuc,
    this.gioiTinh,
    this.bangCap,
    this.kinhNghiem,
    this.minRating,
    this.maxRating,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    // Chuyên môn
    if (chuyenMon != null && chuyenMon!.isNotEmpty) {
      // Nếu chuyenMon là ID dạng số
      final subjectId = int.tryParse(chuyenMon!);
      if (subjectId != null) {
        result['subject_id'] = subjectId;
      } else {
        // Nếu là text thì tìm theo keyword chuyên ngành
        result['keyword'] = chuyenMon;
      }
    }

    // Khu vực -> Map sang 'location' để Controller bắt được
    if (khuVuc != null && khuVuc!.isNotEmpty) {
      result['location'] = khuVuc;
    }

    // Giới tính
    if (gioiTinh != null && gioiTinh!.isNotEmpty) {
      result['gender'] = gioiTinh;
    }

    // Bằng cấp
    if (bangCap != null && bangCap!.isNotEmpty) {
      result['education_level'] = bangCap;
    }

    // Kinh nghiệm
    if (kinhNghiem != null && kinhNghiem!.isNotEmpty) {
      result['experience_level'] = kinhNghiem;
    }

    // Rating
    if (minRating != null) result['min_rating'] = minRating;
    if (maxRating != null) result['max_rating'] = maxRating;

    return result;
  }

  bool get hasActiveFilters {
    return chuyenMon != null ||
        khuVuc != null ||
        gioiTinh != null ||
        bangCap != null ||
        kinhNghiem != null ||
        minRating != null ||
        maxRating != null;
  }

  TutorFilter copyWith({
    Object? chuyenMon = const _Undefined(),
    Object? khuVuc = const _Undefined(),
    Object? gioiTinh = const _Undefined(),
    Object? bangCap = const _Undefined(),
    Object? kinhNghiem = const _Undefined(),
    Object? minRating = const _Undefined(),
    Object? maxRating = const _Undefined(),
  }) {
    return TutorFilter(
      chuyenMon:
          chuyenMon is _Undefined ? this.chuyenMon : chuyenMon as String?,
      khuVuc: khuVuc is _Undefined ? this.khuVuc : khuVuc as String?,
      gioiTinh: gioiTinh is _Undefined ? this.gioiTinh : gioiTinh as String?,
      bangCap: bangCap is _Undefined ? this.bangCap : bangCap as String?,
      kinhNghiem:
          kinhNghiem is _Undefined ? this.kinhNghiem : kinhNghiem as String?,
      minRating:
          minRating is _Undefined ? this.minRating : minRating as String?,
      maxRating:
          maxRating is _Undefined ? this.maxRating : maxRating as String?,
    );
  }

  TutorFilter clearAll() {
    return TutorFilter();
  }
}

class _Undefined {
  const _Undefined();
}
