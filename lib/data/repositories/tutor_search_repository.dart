import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/giasu_model.dart';
import '../models/tutor_filter_model.dart';
import '../../api/api_response.dart';
import '../../api/api_config.dart';

class TutorSearchRepository {
  // Sử dụng ApiConfig.baseUrl thay vì hardcode
  static String get baseUrl => ApiConfig.baseUrl;

  Future<ApiResponse<List<Tutor>>> searchTutors({
    String? query,
    TutorFilter? filter,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/giasu/search');
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (query != null && query.isNotEmpty) {
        queryParams['keyword'] = query;
      }

      if (filter != null) {
        filter.toJson().forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
      }

      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        finalUri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> tutorsJson = data['data'];
          final List<Tutor> tutors =
              tutorsJson.map((json) => Tutor.fromJson(json)).toList();
          return ApiResponse(
            success: true,
            message: 'Thành công',
            data: tutors,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Có lỗi xảy ra',
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Lỗi kết nối server: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getFilterOptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter-options'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final filterData = data['data'] as Map<String, dynamic>;
          final Map<String, dynamic> options = {};

          filterData.forEach((key, value) {
            if (value is List) {
              // Lưu cả thông tin ID và tên cho subjects
              if (key == 'subjects') {
                options[key] =
                    value.map((item) {
                      if (item is Map<String, dynamic>) {
                        return {'id': item['MonID'], 'name': item['TenMon']};
                      }
                      return item;
                    }).toList();
              } else {
                // Các filter khác vẫn giữ nguyên
                options[key] =
                    value.map((item) {
                      if (item is Map<String, dynamic>) {
                        switch (key) {
                          case 'grades':
                            return item['BacHoc']?.toString() ??
                                item.values.first.toString();
                          case 'targets':
                            return item['TenDoiTuong']?.toString() ??
                                item.values.first.toString();
                          default:
                            return item['label']?.toString() ??
                                item.values.first.toString();
                        }
                      }
                      return item.toString();
                    }).toList();
              }
            }
          });

          return ApiResponse(
            success: true,
            message: 'Thành công',
            data: options,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Có lỗi xảy ra',
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Lỗi kết nối server: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
      );
    }
  }
}
