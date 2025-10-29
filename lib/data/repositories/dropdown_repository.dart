// FILE: dropdown_repository.dart
// (Thay thế toàn bộ file này)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';

// Model chung cho dữ liệu dropdown
class DropdownItem {
  final int id;
  final String ten;

  DropdownItem({required this.id, required this.ten});

  // Hàm factory để đọc JSON
  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    // Tìm key đầu tiên là ID (ví dụ: "MonID")
    final idKey = json.keys.firstWhere((k) => k.endsWith('ID'));
    // Tìm key thứ hai là Tên (ví dụ: "TenMon", "BacHoc")
    final tenKey = json.keys.firstWhere((k) => !k.endsWith('ID') && k != 'SoBuoi'); // Bỏ qua 'SoBuoi' cho ThoiGianDay

    // Xử lý đặc biệt cho ThoiGianDay (nếu có)
    if (json.containsKey('BuoiHoc') && json.containsKey('SoBuoi')) {
       return DropdownItem(
        id: json['ThoiGianDayID'] as int,
        ten: "${json['BuoiHoc']} (${json['SoBuoi']})",
      );
    }
    
    return DropdownItem(
      id: json[idKey] as int,
      ten: json[tenKey] as String,
    );
  }
}

class DropdownRepository {
  final ApiService _apiService = ApiService();

  // Hàm chung để gọi bất kỳ endpoint nào
  // SỬA LỖI: endpoint giờ chỉ là '/monhoc', ApiService sẽ tự thêm baseUrl
  Future<List<DropdownItem>> _fetchDropdownList(String endpoint) async {
    
    // ApiService.get sẽ tự động ghép: ApiConfig.baseUrl + endpoint
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint, // Ví dụ: chỉ truyền '/monhoc'
      fromJsonT: (json) => json,
    );

    if (response.isSuccess && response.data != null && response.data!['data'] is List) {
      final List<dynamic> dataList = response.data!['data'];
      return dataList.map((item) => DropdownItem.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      // Ném ra lỗi nếu API thất bại
      throw Exception('Không thể tải dữ liệu cho: ${ApiConfig.baseUrl}$endpoint (Lỗi: ${response.message})');
    }
  }

  // Các hàm cụ thể cho từng loại dropdown
  // SỬA LỖI: Chỉ truyền đường dẫn tương đối (bỏ ApiConfig.baseUrl)
  
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