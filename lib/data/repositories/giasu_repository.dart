import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';

class TutorRepository {
  final ApiService _apiService = ApiService();

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
}