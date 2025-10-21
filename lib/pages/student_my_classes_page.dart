// File: student_my_classes_page.dart

import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/add_class_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/pages/student_class_detail_page.dart';
// THAY THẾ: Import model và dữ liệu giả lập từ data/LopHoc.dart
// import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/LopHoc.dart'; 

class StudentMyClassesPage extends StatelessWidget {
  const StudentMyClassesPage({super.key});

  // Khai báo index cho các tab
  static const int homeIndex = 0;
  static const int scheduleIndex = 1; // Giả định index 1 là Lịch học
  static const int myClassesIndex = 2; // Giả định index 2 là Lớp của tôi (Tài khoản)
  static const int settingsIndex = 3; // Giả định index 3 là Cài đặt/Tài khoản

  // Hàm tiện ích để xây dựng hàng thông tin với Icon
  Widget _buildInfoRow(IconData icon, String text, [Color? iconColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // === Widget xây dựng thẻ lớp học (Đã cập nhật Navigator) ===
  Widget _buildClassCard(BuildContext context, MyClass myClass) {
    bool isActive = myClass.status == 'Đang dạy';
    bool isPending = myClass.status == 'Chờ duyệt';

    return GestureDetector( // Thêm GestureDetector
      onTap: () {
        // 1. Chuẩn bị dữ liệu chi tiết (ClassDetail)
        final ClassDetail detailData = myClass.isPendingForTutor 
            ? ClassDetail.sample() // Lớp chờ duyệt dùng dữ liệu mẫu
            : ClassDetail(
                  // Lớp đang dạy dùng dữ liệu giả định
                  status: myClass.status,
                  id: myClass.id,
                  name: myClass.name,
                  type: 'Gia sư tại nhà', 
                  sessionsPerWeek: 3, 
                  sessionDuration: '2h/buổi', 
                  numberOfStudents: 1, 
                  address: myClass.address,
                  requestorName: myClass.tutorName, 
                  requestorPhone: 'Chưa cập nhật', 
                  fee: myClass.fee,
                  totalFee: myClass.totalFee,
                  requirements: 'Lớp đang hoạt động.',
                  scheduleInfo: 'Vui lòng nhấn "Xem lịch" để xem chi tiết.',
                  availableSlots: {},
              );

        // 2. SỬ DỤNG Navigator.pushNamed để điều hướng đến '/class-detail'
        // Truyền đối tượng detailData qua arguments
        Navigator.pushNamed(
          context,
          '/class-detail',
          arguments: detailData, 
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã lớp + Tên lớp + Mũi tên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Mã lớp: ${myClass.id} - ${myClass.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade700), 
              ],
            ),
            
            const SizedBox(height: 8),

            // Tên gia sư
            _buildInfoRow(Icons.person, myClass.tutorName, Colors.grey),

            // Địa chỉ
            _buildInfoRow(Icons.location_on, myClass.address, Colors.grey),
            
            // Phí/Buổi
            _buildInfoRow(
              Icons.attach_money,
              '${myClass.fee.toStringAsFixed(0)} vnđ/Buổi',
              Colors.grey
            ),
            
            // Phí nhận lớp 
            if (isActive || isPending)
              _buildInfoRow(
                Icons.receipt_long,
                'Phí nhận lớp: ${myClass.totalFee.toStringAsFixed(0)} vnđ',
                Colors.grey
              ),

            const SizedBox(height: 8),

            // Trạng thái + nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Trạng thái
                Row(
                  children: [
                    Icon(
                      isActive ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      size: 16,
                      color: isActive ? Colors.green : isPending ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Trạng thái: ${myClass.status}',
                      style: TextStyle(
                        color: isActive ? Colors.green : isPending ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Nút hành động
                if (isActive)
                  // Nút "Xem lịch"
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Xem lịch'),
                  )
                else if (isPending)
                  // Nút "Sửa" và "Đóng"
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Sửa'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Giả lập danh sách lớp học
    final List<MyClass> myClasses = [
      MyClass(
        id: '0001',
        name: 'Anh văn 12 + Toán',
        tutorName: 'Trần Minh Luân',
        address: 'Ấp 5, tân tây, gò công đông, tiền giang',
        fee: 180000,
        totalFee: 650000,
        status: 'Đang dạy',
        isPendingForTutor: false, 
      ),
      MyClass(
        id: '0001', 
        name: 'Anh văn 12 + Toán',
        tutorName: 'Trần Minh Luân',
        address: 'Ấp 5, tân tây, gò công đông, tiền giang',
        fee: 180000,
        totalFee: 650000,
        status: 'Chờ duyệt',
        isPendingForTutor: true, 
      ),
    ];

    return Scaffold(
      // === AppBar: Giữ nguyên ===
      appBar: AppBar(
        title: const Text(
          'LỚP CỦA TÔI',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddClassPage()),
                );
                // TODO: Logic thêm lớp mới
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Thêm Lớp'),
            ),
          )
        ],
      ),

      // === Body: Hiển thị danh sách ===
      body: myClasses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.class_outlined, size: 50, color: Colors.black54),
                    const SizedBox(height: 16),
                    const Text(
                      'Hiện tại chưa có lớp nào, bạn hãy đăng yêu cầu lớp học nhé.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        
                        // TODO: Logic điều hướng đến trang tạo yêu cầu lớp học
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Đăng Yêu Cầu Lớp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myClasses.length,
              itemBuilder: (context, index) {
                final myClass = myClasses[index];
                return _buildClassCard(context, myClass);
              },
            ),

    );
  }
}

// Model class vẫn giữ nguyên
class MyClass {
  final String id;
  final String name;
  final String tutorName;
  final String address;
  final double fee;
  final double totalFee;
  final String status;
  final bool isPendingForTutor; 

  MyClass({
    required this.id,
    required this.name,
    required this.tutorName,
    required this.address,
    required this.fee,
    required this.totalFee,
    required this.status,
    this.isPendingForTutor = false,
  });
}