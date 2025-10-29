// FILE: lophoc_repository.dart
// (Toàn bộ file đã được cập nhật)

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';

class LopHocRepository {
  final ApiService _apiService = ApiService();

  // === HÀM ĐÃ SỬA LẠI ===
  // (Sửa từ 'getLopHocTimGiaSu' thành hàm chung)
  Future<ApiResponse<List<LopHoc>>> getLopHocByTrangThai(String trangThai) async {
    // 1. Định nghĩa endpoint động
    // Giờ đây bạn có thể truyền 'TimGiaSu', 'DangHoc', 'ChoDuyet'...
    final String endpoint = '${ApiConfig.lopHocYeuCau}?trang_thai=$trangThai';

    try {
      // 2. Gọi ApiService
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json, 
      );

      // 3. Xử lý logic parse
      if (response.statusCode >= 200 && response.statusCode < 300 && response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> lopHocDataList = responseData['data'];

          List<LopHoc> lopHocList = [];
          try {
            lopHocList = lopHocDataList
                .map((lopHocJson) => LopHoc.fromJson(lopHocJson as Map<String, dynamic>))
                .toList();
          } catch (e, stackTrace) {
            print('!!!!!! LỖI KHI PARSE JSON THÀNH LOPHOC (getByTrangThai) !!!!!!');
            print('Lỗi: $e');
            print('Stack trace: $stackTrace');
            return ApiResponse<List<LopHoc>>(
              success: false,
              message: 'Lỗi parse dữ liệu lớp học từ API: $e',
              statusCode: response.statusCode,
            );
          }

          return ApiResponse<List<LopHoc>>(
            success: true,
            message: response.message,
            data: lopHocList,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<List<LopHoc>>(
            success: false,
            message: "API trả về dữ liệu không đúng định dạng (thiếu key 'data' hoặc không phải List).",
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<List<LopHoc>>(
          success: false,
          message: response.message.isNotEmpty ? response.message : 'Lỗi gọi API hoặc dữ liệu trả về không hợp lệ.',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print("!!!!!! LỖI NGOẠI LỆ KHI GỌI/XỬ LÝ API (getByTrangThai) !!!!!!");
      print("Lỗi: $e");
      print("Stack trace: $stackTrace");
      return ApiResponse<List<LopHoc>>(
        success: false,
        message: 'Lỗi không xác định khi lấy danh sách lớp: $e',
        statusCode: 0,
      );
    }
  }

  // === HÀM GIỮ NGUYÊN ===
  // (Dùng cho trang chi tiết lớp học)
  Future<ApiResponse<LopHoc>> getLopHocById(int id) async {
    final String endpoint = '${ApiConfig.lopHocYeuCau}/$id';
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> lopHocJson = responseData['data'];
          try {
            final LopHoc lopHoc = LopHoc.fromJson(lopHocJson);
            return ApiResponse<LopHoc>(
              success: true,
              message: response.message,
              data: lopHoc,
              statusCode: response.statusCode,
            );
          } catch (e, stackTrace) {
            print('!!!!!! LỖI KHI PARSE JSON THÀNH LOPHOC (Get By ID) !!!!!!');
            print('Lỗi: $e');
            print('Stack trace: $stackTrace');
            return ApiResponse<LopHoc>(
              success: false,
              message: 'Lỗi parse dữ liệu chi tiết lớp học từ API: $e',
              statusCode: response.statusCode,
            );
          }
        } else {
          return ApiResponse<LopHoc>(
            success: false,
            message: "API trả về dữ liệu không đúng định dạng (thiếu key 'data' hoặc không phải Object).",
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<LopHoc>(
          success: false,
          message: response.message.isNotEmpty ? response.message : 'Lỗi gọi API chi tiết hoặc dữ liệu trả về không hợp lệ.',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print("!!!!!! LỖI NGOẠI LỆ KHI GỌI/XỬ LÝ API (Get By ID) !!!!!!");
      print("Lỗi: $e");
      print("Stack trace: $stackTrace");
      return ApiResponse<LopHoc>(
        success: false,
        message: 'Lỗi không xác định khi lấy chi tiết lớp: $e',
        statusCode: 0,
      );
    }
  }

  // === HÀM MỚI THÊM VÀO ===
  // (Dùng cho chức năng "Thêm Lớp")
  // Trong file lophoc_repository.dart

  // Hàm tạo lớp học mới
  Future<ApiResponse<LopHoc>> createLopHoc(Map<String, dynamic> lopHocData) async {
    // 1. Định nghĩa endpoint
    const String endpoint = ApiConfig.lopHocYeuCau;

    try {
      // 2. Gọi ApiService.post để gửi dữ liệu
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint,
        data: lopHocData, // Dữ liệu lớp học từ form
        fromJsonT: (json) => json, // Lấy raw JSON response
      );

      // 3. Xử lý response từ backend
      // Kiểm tra xem backend có trả về status 201 (Created) và có dữ liệu không
      if (response.statusCode == 201 && response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;

        // Backend Laravel thường trả về đối tượng mới tạo trong key 'data'
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          // Lấy object JSON của lớp học mới
          final Map<String, dynamic> lopHocJson = responseData['data'];
          try {
            // Thử parse JSON thành đối tượng LopHoc
            final LopHoc newLopHoc = LopHoc.fromJson(lopHocJson);
            // Nếu parse thành công, trả về kết quả thành công với đối tượng LopHoc mới
            return ApiResponse<LopHoc>(
              success: true,
              message: response.message, // Lấy message từ ApiService (thường là rỗng nếu thành công)
              data: newLopHoc,
              statusCode: response.statusCode,
            );
          } catch (e, stackTrace) { // Bắt lỗi nếu LopHoc.fromJson thất bại
            // ====> ĐÂY LÀ DÒNG PRINT DEBUG <====
            print('!!!!!! LỖI KHI PARSE JSON LỚP VỪA TẠO !!!!!!');
            print('JSON Gây Lỗi: $lopHocJson'); // In ra JSON gây lỗi
            // ====> KẾT THÚC DÒNG PRINT DEBUG <====
            print('Lỗi Chi Tiết: $e');
            print('Stack Trace: $stackTrace');
            // Trả về lỗi parse
            return ApiResponse<LopHoc>(
              success: false,
              message: 'Lỗi parse dữ liệu lớp học vừa tạo: $e', // Chính là lỗi bạn thấy trên màn hình
              statusCode: response.statusCode,
            );
          }
        } else {
          // Xử lý trường hợp JSON response từ backend thiếu key 'data' hoặc kiểu dữ liệu sai
          return ApiResponse<LopHoc>(
            success: false,
            message: "API trả về dữ liệu không đúng định dạng (thiếu key 'data' hoặc không phải Object).",
            statusCode: response.statusCode,
          );
        }
      } else {
        // Xử lý các lỗi khác từ API (ví dụ: lỗi 422 Validation, lỗi 500 khác...)
        return ApiResponse<LopHoc>(
          success: false,
          message: response.message.isNotEmpty ? response.message : 'Tạo lớp thất bại.', // Lấy message lỗi từ ApiService
          error: response.error, // Lỗi chi tiết (nếu có, ví dụ lỗi validation)
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // Bắt các lỗi không mong muốn (ví dụ: lỗi mạng, lỗi Flutter...)
      print("!!!!!! LỖI NGOẠI LỆ KHI GỌI API TẠO LỚP !!!!!!");
      print("Lỗi: $e");
      return ApiResponse<LopHoc>(
        success: false,
        message: 'Lỗi không xác định khi tạo lớp: $e',
        statusCode: 0, // Không có status code nếu lỗi mạng
      );
    }
  }
}

  // TODO: Bạn cũng sẽ cần các hàm updateLopHoc (PUT) và deleteLopHoc (DELETE)
  // cho các nút "Sửa" và "Đóng"
//} // Đóng class LopHocRepository (nếu cần)