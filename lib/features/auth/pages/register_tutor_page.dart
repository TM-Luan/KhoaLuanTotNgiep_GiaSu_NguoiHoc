// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/core/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/core/widgets/custom_text_field.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/features/auth/widgets/custom_button.dart';
import 'dart:io';
class RegisterTutorPage extends StatefulWidget {
  const RegisterTutorPage({super.key});

  @override
  State<RegisterTutorPage> createState() => _RegisterTutorPageState();
}

class _RegisterTutorPageState extends State<RegisterTutorPage> {
  // --- Controllers cho Thông tin tài khoản ---
  final hoTenCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final soDienThoaiCtrl = TextEditingController();
  final diaChiCtrl = TextEditingController();
  final matKhauCtrl = TextEditingController();
  final xacNhanMatKhauCtrl = TextEditingController();

  // --- Controllers cho Hồ sơ chuyên môn ---
  final chuyenMonCtrl = TextEditingController();
  final kinhNghiemCtrl = TextEditingController();
  final hocVanCtrl = TextEditingController();

  // --- Biến để lưu trữ file đã chọn ---
  List<File> _selectedFiles = [];

  // --- Hàm chọn file ---
  Future<void> _pickFiles() async {
    // Sử dụng package file_picker để mở trình chọn file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Cho phép chọn nhiều file
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'], // Giới hạn loại file
    );

    if (result != null) {
      setState(() {
        // Cập nhật danh sách file đã chọn vào state để rebuild UI
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    } else {
      // Người dùng đã hủy việc chọn file
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Đăng ký Gia sư'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái cho các tiêu đề
            children: [
              // Phần logo và tiêu đề chính vẫn giữ ở giữa
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', width: 80, height: 80),
                    const SizedBox(height: 10),
                    const Text('Tạo tài khoản Gia sư', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Form Thông tin tài khoản ---
              const Text('1. Thông tin tài khoản', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CustomTextField(label: 'Họ và Tên', icon: Icons.person_outline, controller: hoTenCtrl, maxLines: 1),
              const SizedBox(height: 15),
              CustomTextField(label: 'Email', icon: Icons.email_outlined, controller: emailCtrl, maxLines: 1),
              const SizedBox(height: 15),
              CustomTextField(label: 'Số điện thoại', icon: Icons.phone_outlined, controller: soDienThoaiCtrl, maxLines: 1),
              const SizedBox(height: 15),
              CustomTextField(label: 'Địa chỉ', icon: Icons.home_outlined, controller: diaChiCtrl, maxLines: 1),
              const SizedBox(height: 15),
              CustomTextField(label: 'Mật khẩu', icon: Icons.lock_outline, obscureText: true, controller: matKhauCtrl, maxLines: 1),
              const SizedBox(height: 15),
              CustomTextField(label: 'Xác nhận mật khẩu', icon: Icons.lock_outline, obscureText: true, controller: xacNhanMatKhauCtrl, maxLines: 1),
              const SizedBox(height: 30),

              // --- Form Hồ sơ chuyên môn ---
              const Text('2. Thông tin chuyên môn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CustomTextField(label: 'Chuyên môn (VD: Toán, Lý, Hóa)', icon: Icons.school_outlined, controller: chuyenMonCtrl, maxLines: 1),
              const SizedBox(height: 15),
              CustomTextField(label: 'Học vấn (VD: Sinh viên năm 3 ĐH Bách Khoa)', icon: Icons.history_edu_outlined, controller: hocVanCtrl, maxLines: 1),
              const SizedBox(height: 15),
              CustomTextField(label: 'Kinh nghiệm (VD: 2 năm kinh nghiệm dạy kèm)', icon: Icons.work_outline, controller: kinhNghiemCtrl, maxLines: 3),
              const SizedBox(height: 30),

              // --- PHẦN TẢI FILE MINH CHỨNG ---
              const Text('3. Minh chứng (Bằng cấp, chứng chỉ...)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Chọn tệp hoặc hình ảnh"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _pickFiles, // Gọi hàm chọn file khi nhấn
              ),
              const SizedBox(height: 10),

              // Hiển thị danh sách các tệp đã chọn
              // ListView.builder được dùng để render danh sách file một cách hiệu quả
              ListView.builder(
                shrinkWrap: true, // Cần thiết khi lồng ListView trong SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Ngăn ListView tự cuộn
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  // Lấy tên file từ đường dẫn đầy đủ
                  final fileName = _selectedFiles[index].path.split('/').last;
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryBlue),
                      title: Text(
                        fileName,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Nút xóa file khỏi danh sách
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _selectedFiles.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              // --- KẾT THÚC PHẦN TẢI FILE ---

              const SizedBox(height: 30),
              CustomButton(
                text: 'HOÀN TẤT ĐĂNG KÝ',
                onPressed: () {
                  // Xử lý logic đăng ký gia sư, bao gồm cả việc upload các file trong _selectedFiles
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}