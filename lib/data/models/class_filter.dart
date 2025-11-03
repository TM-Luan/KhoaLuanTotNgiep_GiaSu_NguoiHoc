class ClassFilter {
  final String? monHoc;
  final String? khuVuc;
  final String? minHocPhi;
  final String? maxHocPhi;
  final String? capHoc;
  final String? trangThai;

  ClassFilter({
    this.monHoc,
    this.khuVuc,
    this.minHocPhi,
    this.maxHocPhi,
    this.capHoc,
    this.trangThai,
  });

  Map<String, dynamic> toJson() {
    return {
      if (monHoc != null) 'subject_id': int.tryParse(monHoc!) ?? monHoc,
      if (khuVuc != null) 'location': khuVuc,
      if (minHocPhi != null) 'min_price': minHocPhi,
      if (maxHocPhi != null) 'max_price': maxHocPhi,
      if (capHoc != null) 'grade_id': int.tryParse(capHoc!) ?? capHoc,
      if (trangThai != null) 'status': trangThai,
    };
  }

  bool get hasActiveFilters {
    return monHoc != null ||
        khuVuc != null ||
        minHocPhi != null ||
        maxHocPhi != null ||
        capHoc != null ||
        trangThai != null;
  }

  ClassFilter copyWith({
    String? monHoc,
    String? khuVuc,
    String? minHocPhi,
    String? maxHocPhi,
    String? capHoc,
    String? trangThai,
  }) {
    return ClassFilter(
      monHoc: monHoc ?? this.monHoc,
      khuVuc: khuVuc ?? this.khuVuc,
      minHocPhi: minHocPhi ?? this.minHocPhi,
      maxHocPhi: maxHocPhi ?? this.maxHocPhi,
      capHoc: capHoc ?? this.capHoc,
      trangThai: trangThai ?? this.trangThai,
    );
  }

  ClassFilter clearAll() {
    return ClassFilter();
  }
}