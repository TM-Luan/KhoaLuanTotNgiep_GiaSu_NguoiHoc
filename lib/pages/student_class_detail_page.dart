import 'package:flutter/material.dart';

// Model chứa dữ liệu chi tiết của một lớp học, cần cho trang Chi tiết
class ClassDetail {
  final String status;
  final String id;
  final String name;
  final String type; // Hình thức: Gia sư online (Zoom)
  final int sessionsPerWeek;
  final String sessionDuration; // Ví dụ: 2h/buổi
  final int numberOfStudents;
  final String address;
  final String requestorName;
  final String requestorPhone;
  final double fee; // Học phí/Buổi
  final double totalFee; // Phí nhận lớp
  final String requirements; // Yêu cầu bổ sung
  final String scheduleInfo; // Thông tin lịch học (Lịch thứ 4 từ 14h-16h hoặc 17h-19h)
  final Map<int, List<String>> availableSlots; // Lịch chi tiết

  ClassDetail({
    required this.status,
    required this.id,
    required this.name,
    required this.type,
    required this.sessionsPerWeek,
    required this.sessionDuration,
    required this.numberOfStudents,
    required this.address,
    required this.requestorName,
    required this.requestorPhone,
    required this.fee,
    required this.totalFee,
    required this.requirements,
    required this.scheduleInfo,
    required this.availableSlots,
  });

  // Tạo một instance mẫu cho lớp "Chờ duyệt" (Hình 2)
  static ClassDetail samplePendingClass() {
    return ClassDetail(
      status: 'Đang tìm gia sư',
      id: '0001',
      name: 'Anh văn 12 + Toán',
      type: 'Gia sư online (Zoom)',
      sessionsPerWeek: 3,
      sessionDuration: '2h/buổi',
      numberOfStudents: 1,
      address: 'Ấp 5, tân tây, gò công đông, tiền giang',
      requestorName: 'Trần Minh Luân',
      requestorPhone: '0369137204',
      fee: 180000,
      totalFee: 650000,
      requirements: '- Học sinh nam trường công, học khá\n- Yêu cầu gia sư có kinh nghiệm dạy chắc cơ bản xen lẫn nâng cao',
      scheduleInfo: '- Lịch thứ 4 từ 14h-16h hoặc 17h-19h',
      availableSlots: {
        // key: thứ (2=Thứ 2, 7=Chủ nhật)
        // value: [Buổi sáng, Buổi chiều, Buổi tối]
        4: ['Buổi chiều', 'Buổi tối'], // Thứ 4 có Buổi chiều, Buổi tối (màu xanh lá)
      },
    );
  }
}

// === TRANG CHI TIẾT LỚP HỌC ===
class ClassDetailPage extends StatelessWidget {
  final ClassDetail classDetail;
  const ClassDetailPage({super.key, required this.classDetail});

  // Hàm tiện ích để xây dựng một hàng thông tin
  Widget _buildInfoRow(IconData icon, String label, String value, {bool isStatus = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                color: statusColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng ô thời gian
  Widget _buildTimeSlotButton(String text, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade400 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? Colors.green.shade600 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isAvailable ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  // Widget xây dựng lịch học
  Widget _buildScheduleTable() {
    const List<String> days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6'];
    const List<String> slots = ['Buổi sáng', 'Buổi chiều', 'Buổi tối'];
    final Map<int, List<String>> available = classDetail.availableSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < days.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(days[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: slots.map((slot) {
                      // Thứ 2 = index 0 => thứ 2 thực tế là key 2
                      bool isAvailable = available[i + 2]?.contains(slot) ?? false;
                      return _buildTimeSlotButton(slot, isAvailable);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHI TIẾT LỚP HỌC',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Quay lại trang trước
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trạng thái
              _buildInfoRow(
                Icons.description,
                'Trạng thái',
                'Trạng thái: ${classDetail.status}',
                isStatus: true,
                statusColor: Colors.red.shade700,
              ),
              const Divider(),

              // Thông tin cơ bản
              _buildInfoRow(Icons.apps, 'Mã lớp', 'Mã lớp: ${classDetail.id} - ${classDetail.name}'),
              _buildInfoRow(Icons.online_prediction, 'Hình thức', 'Hình thức: ${classDetail.type}'),
              _buildInfoRow(Icons.calendar_month, 'Số buổi/tuần', 'Số buổi/tuần: ${classDetail.sessionsPerWeek} buổi (${classDetail.sessionDuration})'),
              _buildInfoRow(Icons.person, 'Số học viên', 'Số học viên: ${classDetail.numberOfStudents}'),
              _buildInfoRow(Icons.location_on, 'Địa chỉ', 'Địa chỉ: ${classDetail.address}'),
              _buildInfoRow(Icons.person_pin, 'Người yêu cầu', 'Người yêu cầu: ${classDetail.requestorName}'),
              _buildInfoRow(Icons.phone, 'Số điện thoại', 'Số điện thoại: ${classDetail.requestorPhone}'),
              _buildInfoRow(Icons.attach_money, 'Học phí/Buổi', 'Học phí/Buổi: ${classDetail.fee.toStringAsFixed(0)} vnđ/2h'),
              _buildInfoRow(Icons.receipt_long, 'Phí nhận lớp', 'Phí nhận lớp: ${classDetail.totalFee.toStringAsFixed(0)} vnđ'),
              
              const SizedBox(height: 16),
              
              // Yêu cầu và Lịch
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classDetail.requirements,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      classDetail.scheduleInfo,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lịch chi tiết
              _buildScheduleTable(),
              
              const SizedBox(height: 16),
              const Divider(),
              
              // Đề nghị dạy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đã có 1/6 đề nghị dạy',
                    style: TextStyle(color: Colors.grey),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Xem đề nghị'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}