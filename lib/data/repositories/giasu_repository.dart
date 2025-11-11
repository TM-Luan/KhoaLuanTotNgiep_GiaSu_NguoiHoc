import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';

class TutorRepository {
  final ApiService _apiService = ApiService();

  /// Lấy danh sách tất cả gia sư
  Future<ApiResponse<List<Tutor>>> getAllTutors() async {
    return await _apiService.get<List<Tutor>>(
      '/giasu',
      // SỬA: 'data' (trước đây là 'json') bây giờ là List [ ... ]
      // vì ApiService đã mở gói { 'data': [...] }
      fromJsonT: (data) {
        if (data is List) {
          return (data)
              .map((item) => Tutor.fromJson(item))
              .toList();
        }
        return [];
      },
    );
  }

  /// Lấy thông tin chi tiết 1 gia sư
  Future<ApiResponse<Tutor>> getTutorById(int id) async {
    return await _apiService.get<Tutor>(
      '/giasu/$id',
      // SỬA: 'data' (trước đây là 'json') bây giờ là đối tượng Tutor { ... }
      // vì ApiService đã mở gói { 'data': {...} }
      fromJsonT: (data) {
        if (data != null) {
          return Tutor.fromJson(data);
        }
        throw Exception('Data not found');
      },
    );
  }

  /// 🔹 Lấy các lớp của gia sư (đang dạy + đề nghị)
  Future<ApiResponse<Map<String, dynamic>>> getTutorClasses(int giaSuId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/giasu/$giaSuId/lop',
      // SỬA: 'data' (trước đây là 'json') bây giờ là Map { 'dang_day': [], 'de_nghi': [] }
      // vì ApiService đã mở gói { 'data': { 'dang_day': [], 'de_nghi': [] } }
      // Chúng ta không cần kiểm tra 'root.containsKey('data')' nữa
      fromJsonT: (data) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        return {
          'dang_day': (map['dang_day'] as List<dynamic>? ?? []),
          'de_nghi': (map['de_nghi'] as List<dynamic>? ?? []),
        };
      },
    );
  }
}