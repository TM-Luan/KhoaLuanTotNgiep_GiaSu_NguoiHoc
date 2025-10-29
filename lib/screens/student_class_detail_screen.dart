// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/class_info_row.dart';
import '../widgets/class_schedule_table.dart';

// ====================== MODEL ======================
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
  final String scheduleInfo; // Thông tin lịch học
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

  // Ví dụ instance mẫu (bạn có thể dùng để test)
  static ClassDetail sample() {
    return ClassDetail(
      status: 'Chờ duyệt',
      id: 'L12345',
      name: 'Toán lớp 9 - Củ Chi',
      type: 'Gia sư online (Zoom)',
      sessionsPerWeek: 3,
      sessionDuration: '2h/buổi',
      numberOfStudents: 1,
      address: '123 Đường Nguyễn Văn Bảo, Gò Vấp, TP.HCM',
      requestorName: 'Nguyễn Văn A',
      requestorPhone: '0909123456',
      fee: 150000,
      totalFee: 200000,
      requirements: 'Yêu cầu gia sư có kinh nghiệm dạy ôn thi lớp 9 lên 10.',
      scheduleInfo: 'Học các buổi Thứ 2, 4, 6 từ 18h - 20h.',
      availableSlots: {
        2: ['Buổi tối'],
        4: ['Buổi tối'],
        6: ['Buổi tối'],
      },
    );
  }
}

// ====================== UI PAGE ======================
class ClassDetailPage extends StatelessWidget {
  final ClassDetail classDetail;
  const ClassDetailPage({super.key, required this.classDetail});

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
          onPressed: () => Navigator.of(context).pop(),
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
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClassInfoRow(
                icon: Icons.description,
                value: 'Trạng thái: ${classDetail.status}',
                isStatus: true,
                statusColor: Colors.red.shade700,
              ),
              const Divider(),
              ClassInfoRow(
                icon: Icons.apps,
                value: 'Mã lớp: ${classDetail.id} - ${classDetail.name}',
              ),
              ClassInfoRow(
                icon: Icons.online_prediction,
                value: 'Hình thức: ${classDetail.type}',
              ),
              ClassInfoRow(
                icon: Icons.calendar_month,
                value:
                    'Số buổi/tuần: ${classDetail.sessionsPerWeek} buổi (${classDetail.sessionDuration})',
              ),
              ClassInfoRow(
                icon: Icons.person,
                value: 'Số học viên: ${classDetail.numberOfStudents}',
              ),
              ClassInfoRow(
                icon: Icons.location_on,
                value: 'Địa chỉ: ${classDetail.address}',
              ),
              ClassInfoRow(
                icon: Icons.person_pin,
                value: 'Người yêu cầu: ${classDetail.requestorName}',
              ),
              ClassInfoRow(
                icon: Icons.phone,
                value: 'Số điện thoại: ${classDetail.requestorPhone}',
              ),
              ClassInfoRow(
                icon: Icons.attach_money,
                value:
                    'Học phí/Buổi: ${classDetail.fee.toStringAsFixed(0)} vnđ/2h',
              ),
              ClassInfoRow(
                icon: Icons.receipt_long,
                value:
                    'Phí nhận lớp: ${classDetail.totalFee.toStringAsFixed(0)} vnđ',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classDetail.requirements,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      classDetail.scheduleInfo,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ClassScheduleTable(availableSlots: classDetail.availableSlots),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Đã có 1/6 đề nghị dạy',
                      style: TextStyle(color: Colors.grey)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Xem đề nghị'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
