// data/repositories/lich_hoc_repository.dart
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lichhoc.dart';

class LichHocRepository {
  final ApiService _apiService = ApiService();

  // Lấy lịch học theo lớp (cho cả gia sư và người học)
  Future<ApiResponse<List<LichHoc>>> getLichHocTheoLop(int lopYeuCauId) async {
    final endpoint = '${ApiConfig.lichHocTheoLop}/$lopYeuCauId/lich-hoc';
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      return _parseLichHocListResponse(response);
    } catch (e) {
      return ApiResponse<List<LichHoc>>(
        success: false,
        message: 'Lỗi khi lấy lịch học theo lớp: $e',
        statusCode: 0,
      );
    }
  }

  // Lấy lịch học của gia sư
  Future<ApiResponse<List<LichHoc>>> getLichHocCuaGiaSu() async {
    const endpoint = ApiConfig.lichHocCuaGiaSu;
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      return _parseLichHocListResponse(response);
    } catch (e) {
      return ApiResponse<List<LichHoc>>(
        success: false,
        message: 'Lỗi khi lấy lịch học của gia sư: $e',
        statusCode: 0,
      );
    }
  }

  // Lấy lịch học của người học
  Future<ApiResponse<List<LichHoc>>> getLichHocCuaNguoiHoc() async {
    const endpoint = ApiConfig.lichHocCuaNguoiHoc;
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      return _parseLichHocListResponse(response);
    } catch (e) {
      return ApiResponse<List<LichHoc>>(
        success: false,
        message: 'Lỗi khi lấy lịch học của người học: $e',
        statusCode: 0,
      );
    }
  }

  // Gia sư tạo lịch học
  Future<ApiResponse<LichHoc>> taoLichHocGiaSu({
    required int lopYeuCauId,
    required Map<String, dynamic> lichHocData,
  }) async {
    final endpoint = '${ApiConfig.taoLichHocGiaSu}/$lopYeuCauId/lich-hoc';

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint,
        data: lichHocData,
        fromJsonT: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        // Xử lý nhiều định dạng response khác nhau
        Map<String, dynamic> lichHocJson;
        
        if (response.data!['data'] != null) {
          lichHocJson = response.data!['data'] is Map 
              ? response.data!['data'] 
              : response.data!;
        } else {
          lichHocJson = response.data!;
        }

        final newLichHoc = LichHoc.fromJson(lichHocJson);
        return ApiResponse<LichHoc>(
          success: true,
          message: response.message,
          data: newLichHoc,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<LichHoc>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );

    } catch (e) {
      return ApiResponse<LichHoc>(
        success: false,
        message: 'Lỗi khi tạo lịch học: $e',
        statusCode: 0,
      );
    }
  }

  // Gia sư cập nhật lịch học
  Future<ApiResponse<LichHoc>> capNhatLichHocGiaSu({
    required int lichHocId,
    required Map<String, dynamic> updateData,
  }) async {
    final endpoint = '${ApiConfig.capNhatLichHoc}/$lichHocId';

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint,
        data: updateData,
        fromJsonT: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        Map<String, dynamic> lichHocJson;
        
        if (response.data!['data'] != null) {
          lichHocJson = response.data!['data'] is Map 
              ? response.data!['data'] 
              : response.data!;
        } else {
          lichHocJson = response.data!;
        }

        final updatedLichHoc = LichHoc.fromJson(lichHocJson);
        return ApiResponse<LichHoc>(
          success: true,
          message: response.message,
          data: updatedLichHoc,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<LichHoc>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );

    } catch (e) {
      return ApiResponse<LichHoc>(
        success: false,
        message: 'Lỗi khi cập nhật lịch học: $e',
        statusCode: 0,
      );
    }
  }

  // Helper method để parse response list
  ApiResponse<List<LichHoc>> _parseLichHocListResponse(ApiResponse<Map<String, dynamic>> response) {
    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      
      List<dynamic> lichHocListData = [];
      
      // Xử lý nhiều định dạng response khác nhau
      if (data['data'] != null) {
        if (data['data'] is List) {
          lichHocListData = data['data'];
        } else if (data['data'] is Map && data['data']['lich_hoc'] is List) {
          lichHocListData = data['data']['lich_hoc'];
        } else if (data['data'] is Map && data['data']['data'] is List) {
          lichHocListData = data['data']['data'];
        }
      } else if (data['lich_hoc'] is List) {
        lichHocListData = data['lich_hoc'];
      } else if (data is List) {
        lichHocListData = data as List;
      }
      
      try {
        final lichHocList = lichHocListData
            .map((item) => LichHoc.fromJson(item is Map<String, dynamic> ? item : {}))
            .where((lichHoc) => lichHoc.lichHocID > 0) // Lọc bỏ item không hợp lệ
            .toList();
        
        return ApiResponse<List<LichHoc>>(
          success: true,
          message: response.message,
          data: lichHocList,
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse<List<LichHoc>>(
          success: false,
          message: 'Lỗi parse dữ liệu lịch học: $e',
          statusCode: response.statusCode,
        );
      }
    }

    return ApiResponse<List<LichHoc>>(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Lấy lịch học theo khoảng thời gian (tùy chọn)
  Future<ApiResponse<List<LichHoc>>> getLichHocTheoThoiGian({
    required String tuNgay,
    required String denNgay,
    required bool isGiaSu,
  }) async {
    final baseEndpoint = isGiaSu ? ApiConfig.lichHocCuaGiaSu : ApiConfig.lichHocCuaNguoiHoc;
    final endpoint = '$baseEndpoint?tu_ngay=$tuNgay&den_ngay=$denNgay';

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      return _parseLichHocListResponse(response);
    } catch (e) {
      return ApiResponse<List<LichHoc>>(
        success: false,
        message: 'Lỗi khi lấy lịch học theo thời gian: $e',
        statusCode: 0,
      );
    }
  }
}