import 'package:flutter/material.dart';

class ClassDetailSection extends StatelessWidget {
  final TextEditingController classCodeController;
  final TextEditingController requesterController;
  final TextEditingController phoneController;
  final TextEditingController feeController;
  final TextEditingController receiveFeeController;

  const ClassDetailSection({
    super.key,
    required this.classCodeController,
    required this.requesterController,
    required this.phoneController,
    required this.feeController,
    required this.receiveFeeController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin lớp học chi tiết",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: classCodeController,
              decoration: const InputDecoration(
                labelText: "Mã lớp",
                hintText: "VD: 0001 - Anh văn 12 + Toán",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập mã lớp" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: requesterController,
              decoration: const InputDecoration(
                labelText: "Người yêu cầu",
                hintText: "VD: Trần Minh Luân",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập người yêu cầu" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                hintText: "VD: 0909xxxxxx",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: feeController,
              decoration: const InputDecoration(
                labelText: "Học phí/Buổi",
                hintText: "VD: 180000 vnđ/2h",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập học phí" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: receiveFeeController,
              decoration: const InputDecoration(
                labelText: "Phí nhận lớp",
                hintText: "VD: 650000 vnđ",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập phí nhận lớp" : null,
            ),
          ],
        ),
      ),
    );
  }
}
