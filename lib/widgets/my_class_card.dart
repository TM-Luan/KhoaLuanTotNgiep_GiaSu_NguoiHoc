import 'package:flutter/material.dart';
import '../../pages/student_class_detail_page.dart';

class MyClassCard extends StatelessWidget {
  final MyClass myClass;
  const MyClassCard({super.key, required this.myClass});

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

  @override
  Widget build(BuildContext context) {
    bool isActive = myClass.status == 'Đang dạy';
    bool isPending = myClass.status == 'Chờ duyệt';

    return GestureDetector(
      onTap: () {
        final detailData = myClass.isPendingForTutor
            ? ClassDetail.sample()
            : ClassDetail(
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

        Navigator.pushNamed(context, '/class-detail', arguments: detailData);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('Mã lớp: ${myClass.id} - ${myClass.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade700),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, myClass.tutorName, Colors.grey),
            _buildInfoRow(Icons.location_on, myClass.address, Colors.grey),
            _buildInfoRow(Icons.attach_money, '${myClass.fee.toStringAsFixed(0)} vnđ/Buổi', Colors.grey),
            if (isActive || isPending)
              _buildInfoRow(Icons.receipt_long, 'Phí nhận lớp: ${myClass.totalFee.toStringAsFixed(0)} vnđ', Colors.grey),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isActive ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      size: 16,
                      color: isActive ? Colors.green : isPending ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text('Trạng thái: ${myClass.status}', style: TextStyle(color: isActive ? Colors.green : isPending ? Colors.orange : Colors.grey)),
                  ],
                ),
                if (isActive)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('Xem lịch'),
                  )
                else if (isPending)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        child: const Text('Sửa'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
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
}

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
