import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu_model.dart';

class TutorRepository {
  final ApiService _apiService = ApiService();
  Future<ApiResponse<List<Tutor>>> getAllTutors() async {
    return await _apiService.get<List<Tutor>>(
      '/giasu',
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