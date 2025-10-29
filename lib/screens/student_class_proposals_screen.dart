// FILE 1: TẠO FILE MỚI
// (File này để chữa lỗi import và cho nút "Xem đề nghị" hoạt động)
// Tên file: student_class_proposals_screen.dart

import 'package:flutter/material.dart';

class StudentClassProposalsScreen extends StatefulWidget {
  final int lopHocId;

  const StudentClassProposalsScreen({super.key, required this.lopHocId});

  @override
  State<StudentClassProposalsScreen> createState() =>
      _StudentClassProposalsScreenState();
}

class _StudentClassProposalsScreenState
    extends State<StudentClassProposalsScreen> {
  
  // TODO: Khai báo repository và gọi API
  // ví dụ: _yeuCauRepo.getDanhSachDeNghi(widget.lopHocId)

  @override
  void initState() {
    super.initState();
    // TODO: Gọi API để lấy danh sách các gia sư đã đề nghị
    print('Đang xem danh sách đề nghị cho lớp ID: ${widget.lopHocId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đề Nghị Cho Lớp ${widget.lopHocId}'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Danh sách gia sư đề nghị',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Chức năng này đang được phát triển.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            // TODO: Hiển thị ListView.builder khi có API
          ],
        ),
      ),
    );
  }
}