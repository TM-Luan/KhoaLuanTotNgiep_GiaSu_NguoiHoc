// data/schedule_data.dart

class ThoiGianDay {
  final String maTGD;
  final String thu;
  final String buoi;

  const ThoiGianDay({
    required this.maTGD,
    required this.thu,
    required this.buoi,
  });
}

class LichHoc {
  final String maLH;
  final String tenLop;
  final String tenGiaSu;
  final String monHoc;
  final String diaDiem;
  final String thoiGianBD;
  final String thoiGianKT;
  final String duongDanOnline;
  final List<ThoiGianDay> thoiGianDay;

  const LichHoc({
    required this.maLH,
    required this.tenLop,
    required this.tenGiaSu,
    required this.monHoc,
    required this.diaDiem,
    required this.thoiGianBD,
    required this.thoiGianKT,
    required this.duongDanOnline,
    required this.thoiGianDay,
  });
}
