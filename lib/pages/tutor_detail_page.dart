import 'package:flutter/material.dart';

class TutorDetailPage extends StatelessWidget {
  static const routeName = '/tutor-detail';

  const TutorDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ModalRoute.of(context)?.settings.arguments as Map?;
    return Scaffold(
      appBar: AppBar(title: Text(t?['name'] ?? 'Chi tiết gia sư')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          t != null
              ? 'Gia sư: ${t['name']}\nMôn: ${t['subject']}\nRating: ${t['rating']} (${t['students']} học viên)'
              : 'Không có dữ liệu.',
        ),
      ),
     
    );
  }
}
