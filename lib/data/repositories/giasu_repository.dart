import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';

class TutorRepository {
  final ApiService _apiService = ApiService();

  /// Lấy danh sách tất cả gia sư
  Future<ApiResponse<List<Tutor>>> getAllTutors() async {
    return await _apiService.get<List<Tutor>>(
      '/giasu',
      fromJsonT: (json) {
        if (json['data'] is List) {
          return (json['data'] as List)
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
      fromJsonT: (json) {
        if (json['data'] != null) {
          return Tutor.fromJson(json['data']);
        }
        throw Exception('Data not found');
      },
    );
  }

  /// 🔹 Lấy các lớp của gia sư (đang dạy + đề nghị)
  Future<ApiResponse<Map<String, dynamic>>> getTutorClasses(int giaSuId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/giasu/$giaSuId/lop',
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          // Đảm bảo có cả 2 key, tránh lỗi null
          return {
            'dang_day': (json['dang_day'] as List<dynamic>? ?? []),
            'de_nghi': (json['de_nghi'] as List<dynamic>? ?? []),
          };
        } else {
          throw Exception('Dữ liệu trả về không hợp lệ');
        }
      },
    );
  }
}
