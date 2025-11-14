// FILE: dropdown_repository.dart (ĐÃ SỬA VÀ TỐI ƯU)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';

class DropdownItem {
  final int id;
  final String ten;

  DropdownItem({required this.id, required this.ten});

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    final idKey = json.keys.firstWhere((k) => k.endsWith('ID'));
    final tenKey = json.keys.firstWhere(
      (k) => !k.endsWith('ID') && k != 'SoBuoi',
    );
    if (json.containsKey('BuoiHoc') && json.containsKey('SoBuoi')) {
      return DropdownItem(
        id: json['ThoiGianDayID'] as int,
        ten: "${json['BuoiHoc']} (${json['SoBuoi']})",
      );
    }

    return DropdownItem(id: json[idKey] as int, ten: json[tenKey] as String);
  }
}

class DropdownRepository {
  final ApiService _apiService = ApiService();

  Future<List<DropdownItem>> _fetchDropdownList(String endpoint) async {
    // SỬA: Thay đổi kiểu <Map<String, dynamic>> -> <List<DropdownItem>>
    final response = await _apiService.get<List<DropdownItem>>(
      endpoint,
      // SỬA: Cung cấp logic parse
      fromJsonT: (data) => (data as List)
          .map((item) => DropdownItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    // SỬA: Logic kiểm tra đơn giản hơn
    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw Exception(
        'Không thể tải dữ liệu cho: ${ApiConfig.baseUrl}$endpoint (Lỗi: ${response.message})',
      );
    }
  }

  Future<List<DropdownItem>> getMonHocList() {
    return _fetchDropdownList('/monhoc');
  }

  Future<List<DropdownItem>> getKhoiLopList() {
    return _fetchDropdownList('/khoilop');
  }

  Future<List<DropdownItem>> getDoiTuongList() {
    return _fetchDropdownList('/doituong');
  }

  Future<List<DropdownItem>> getThoiGianDayList() {
    return _fetchDropdownList('/thoigianday');
  }
}