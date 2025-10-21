import 'package:flutter/material.dart';

class BasicInfoSection extends StatelessWidget {
  final Function(String?) onSubjectChanged;
  final Function(String?) onGradeChanged;

  const BasicInfoSection({
    super.key,
    required this.onSubjectChanged,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Nhóm môn học
    final academicSubjects = [
      'Toán',
      'Vật lý',
      'Hóa học',
      'Ngữ văn',
      'Lịch sử',
      'Địa lý',
      'Sinh học',
      'Tin học',
      'Công nghệ'
    ];

    final languageSubjects = [
      'Tiếng Anh',
      'Tiếng Nhật',
      'Tiếng Hàn',
      'Tiếng Trung',
    ];

    // Kết hợp tất cả vào danh sách Dropdown
    final subjectItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          '📘 Môn học phổ thông',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
      ...academicSubjects.map(
        (e) => DropdownMenuItem(value: e, child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(e),
        )),
      ),
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          '🌍 Ngoại ngữ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
      ...languageSubjects.map(
        (e) => DropdownMenuItem(value: e, child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(e),
        )),
      ),
    ];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
              labelText: 'Môn học *', border: OutlineInputBorder()),
          items: subjectItems,
          onChanged: onSubjectChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
              labelText: 'Lớp *', border: OutlineInputBorder()),
          items: List.generate(
            12,
            (i) => DropdownMenuItem(
              value: "${i + 1}",
              child: Text("Lớp ${i + 1}"),
            ),
          ),
          onChanged: onGradeChanged,
        ),
      ],
    );
  }
}
