// FILE 2: TẠO REPOSITORY LỚP HỌC
// Đây là file "Trưởng phòng nghiệp vụ" Lớp học,
// áp dụng y hệt cách làm của auth_repository.dart

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';

class LopHocRepository {
  final ApiService _apiService = ApiService();

  // Hàm để lấy danh sách lớp học "Đang tìm gia sư"
  Future<ApiResponse<List<LopHoc>>> getLopHocTimGiaSu() async {
    // 1. Định nghĩa endpoint cụ thể
    const String endpoint = '${ApiConfig.lopHocYeuCau}?trang_thai=TimGiaSu';

    try {
      // 2. Gọi ApiService - Sử dụng Map<String, dynamic> để nhận toàn bộ JSON trước
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json, // Truyền fromJsonT để lấy raw responseData làm data
      );

      // --- DEBUG PRINT: In ra response thô từ ApiService ---
      print('--- API Service Response ---');
      print('Status Code: ${response.statusCode}');
      print('Success Flag: ${response.success}'); // Do ApiService đặt
      print('Is Success Check: ${response.isSuccess}'); // Kiểm tra cả status code
      print('Message: ${response.message}');
      print('Raw Data Received: ${response.data}');
      print('-----------------------------');
      // --- END DEBUG PRINT ---

      // 3. Xử lý logic parse SAU KHI nhận được response
      // Sử dụng statusCode để kiểm tra thành công vì API không có key 'success'
      if (response.statusCode >= 200 && response.statusCode < 300 && response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data!;

        // Kiểm tra xem có key 'data' và nó là một List không
        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> lopHocDataList = responseData['data'];

          // --- DEBUG PRINT: In ra List JSON trước khi parse ---
          print('--- JSON List to Parse ---');
          print(lopHocDataList);
          print('--------------------------');
          // --- END DEBUG PRINT ---

          // THÊM TRY-CATCH XUNG QUANH .map ĐỂ BẮT LỖI PARSE CỤ THỂ
          List<LopHoc> lopHocList = []; // Khởi tạo list rỗng
          try {
            lopHocList = lopHocDataList
                .map((lopHocJson) {
                  // --- DEBUG PRINT: In ra từng JSON Object trước khi parse ---
                  print('--- Parsing JSON Object ---');
                  print(lopHocJson);
                  print('---------------------------');
                  // --- END DEBUG PRINT ---
                  // Gọi hàm factory trong model LopHoc
                  return LopHoc.fromJson(lopHocJson as Map<String, dynamic>);
                })
                .toList();
          } catch (e, stackTrace) {
            // Nếu lỗi xảy ra trong .map (ví dụ: LopHoc.fromJson bị lỗi)
            print('!!!!!! LỖI KHI PARSE JSON THÀNH LOPHOC !!!!!!');
            print('Lỗi: $e');
            print('Stack trace: $stackTrace');
            print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            // Trả về ApiResponse lỗi với thông báo cụ thể
            return ApiResponse<List<LopHoc>>(
              success: false,
              message: 'Lỗi parse dữ liệu lớp học từ API: $e',
              statusCode: response.statusCode, // Vẫn giữ status code gốc
            );
          }

          // Nếu parse thành công, trả về dữ liệu
          return ApiResponse<List<LopHoc>>(
            success: true,
            message: response.message, // Thường là '' hoặc null nếu API thành công
            data: lopHocList,
            statusCode: response.statusCode,
          );
        } else {
          // Nếu JSON gốc không có key 'data' hoặc không phải List
          print("!!!!!! LỖI: JSON response không chứa key 'data' hoặc 'data' không phải là List !!!!!!");
          print("JSON Response Data Received: $responseData");
          print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          return ApiResponse<List<LopHoc>>(
            success: false,
            message: "API trả về dữ liệu không đúng định dạng (thiếu key 'data' hoặc không phải List).",
            statusCode: response.statusCode,
          );
        }
      } else {
        // Nếu API không thành công (status code không phải 2xx) hoặc data null/sai kiểu
        print("!!!!!! LỖI: Gọi API không thành công hoặc response.data không hợp lệ !!!!!!");
        print("Response Status Code: ${response.statusCode}");
        print("Response Message: ${response.message}");
        print("Response Data: ${response.data}");
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        return ApiResponse<List<LopHoc>>(
          success: false,
          message: response.message.isNotEmpty ? response.message : 'Lỗi gọi API hoặc dữ liệu trả về không hợp lệ.', // Lấy message lỗi từ ApiService
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) { // Bắt lỗi chung khi gọi API (ví dụ: lỗi mạng)
      print("!!!!!! LỖI NGOẠI LỆ KHI GỌI/XỬ LÝ API !!!!!!");
      print("Lỗi: $e");
      print("Stack trace: $stackTrace");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      return ApiResponse<List<LopHoc>>(
        success: false,
        message: 'Lỗi không xác định khi lấy danh sách lớp: $e',
        statusCode: 0, // Không có status code nếu lỗi mạng
      );
    }
  }

  // Bạn có thể thêm các hàm khác ở đây, ví dụ:
  // Future<ApiResponse<LopHoc>> getLopHocById(String id) { ... }
  // Future<ApiResponse<String>> createLopHoc(Map<String, dynamic> data) { ... }
}