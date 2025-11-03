class TutorFilter {
  final String? chuyenMon;
  final String? khuVuc;
  final String? gioiTinh;
  final String? bangCap;
  final String? kinhNghiem; // Thay đổi từ min/max thành single value

  TutorFilter({
    this.chuyenMon,
    this.khuVuc,
    this.gioiTinh,
    this.bangCap,
    this.kinhNghiem,
  });

  Map<String, dynamic> toJson() {
    return {
      if (chuyenMon != null) 'subject_id': int.tryParse(chuyenMon!) ?? chuyenMon,
      if (khuVuc != null) 'location': khuVuc,
      if (gioiTinh != null) 'gender': gioiTinh,
      if (bangCap != null) 'education_level': bangCap,
      if (kinhNghiem != null) 'experience_level': kinhNghiem,
    };
  }

  bool get hasActiveFilters {
    return chuyenMon != null ||
        khuVuc != null ||
        gioiTinh != null ||
        bangCap != null ||
        kinhNghiem != null;
  }

  TutorFilter copyWith({
    String? chuyenMon,
    String? khuVuc,
    String? gioiTinh,
    String? bangCap,
    String? kinhNghiem,
  }) {
    return TutorFilter(
      chuyenMon: chuyenMon ?? this.chuyenMon,
      khuVuc: khuVuc ?? this.khuVuc,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      bangCap: bangCap ?? this.bangCap,
      kinhNghiem: kinhNghiem ?? this.kinhNghiem,
    );
  }

  TutorFilter clearAll() {
    return TutorFilter();
  }
}