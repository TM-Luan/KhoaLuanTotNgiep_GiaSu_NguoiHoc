class ClassFilter {
  final String? monHoc;
  final String? khuVuc;
  final String? minHocPhi;
  final String? maxHocPhi;
  final String? capHoc;
  final String? trangThai;
  final String? hinhThuc; // NEW: Lọc theo hình thức (Online/Offline/Cả hai)

  ClassFilter({
    this.monHoc,
    this.khuVuc,
    this.minHocPhi,
    this.maxHocPhi,
    this.capHoc,
    this.trangThai,
    this.hinhThuc,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    
    // Môn học
    if (monHoc != null && monHoc!.isNotEmpty) {
      final subjectId = int.tryParse(monHoc!);
      if (subjectId != null) {
        result['subject_id'] = subjectId;
      }
    }
    
    // Khu vực
    if (khuVuc != null && khuVuc!.isNotEmpty) {
      result['location'] = khuVuc;
    }
    
    // Giá
    if (minHocPhi != null && minHocPhi!.isNotEmpty) {
      final price = double.tryParse(minHocPhi!) ?? int.tryParse(minHocPhi!);
      if (price != null) {
        result['min_price'] = price;
      }
    }
    
    if (maxHocPhi != null && maxHocPhi!.isNotEmpty) {
      final price = double.tryParse(maxHocPhi!) ?? int.tryParse(maxHocPhi!);
      if (price != null) {
        result['max_price'] = price;
      }
    }
    
    // Cấp học
    if (capHoc != null && capHoc!.isNotEmpty) {
      final gradeId = int.tryParse(capHoc!);
      if (gradeId != null) {
        result['grade_id'] = gradeId;
      }
    }
    
    // Trạng thái
    if (trangThai != null && trangThai!.isNotEmpty) {
      result['status'] = trangThai;
    }
    
    // Hình thức
    if (hinhThuc != null && hinhThuc!.isNotEmpty) {
      result['form'] = hinhThuc;
    }
    
    return result;
  }

  bool get hasActiveFilters {
    return monHoc != null ||
        khuVuc != null ||
        minHocPhi != null ||
        maxHocPhi != null ||
        capHoc != null ||
        trangThai != null ||
        hinhThuc != null;
  }

  ClassFilter copyWith({
    Object? monHoc = const _Undefined(),
    Object? khuVuc = const _Undefined(),
    Object? minHocPhi = const _Undefined(),
    Object? maxHocPhi = const _Undefined(),
    Object? capHoc = const _Undefined(),
    Object? trangThai = const _Undefined(),
    Object? hinhThuc = const _Undefined(),
  }) {
    return ClassFilter(
      monHoc: monHoc is _Undefined ? this.monHoc : monHoc as String?,
      khuVuc: khuVuc is _Undefined ? this.khuVuc : khuVuc as String?,
      minHocPhi: minHocPhi is _Undefined ? this.minHocPhi : minHocPhi as String?,
      maxHocPhi: maxHocPhi is _Undefined ? this.maxHocPhi : maxHocPhi as String?,
      capHoc: capHoc is _Undefined ? this.capHoc : capHoc as String?,
      trangThai: trangThai is _Undefined ? this.trangThai : trangThai as String?,
      hinhThuc: hinhThuc is _Undefined ? this.hinhThuc : hinhThuc as String?,
    );
  }

  ClassFilter clearAll() {
    return ClassFilter();
  }
}

class _Undefined {
  const _Undefined();
}