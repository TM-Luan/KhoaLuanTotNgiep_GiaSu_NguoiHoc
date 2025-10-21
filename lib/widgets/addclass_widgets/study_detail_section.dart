import 'package:flutter/material.dart';

class StudyDetailSection extends StatelessWidget {
  const StudyDetailSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Số buổi học/tuần *',
                  border: OutlineInputBorder(),
                  hintText: 'VD: 3',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Học phí (vnđ/buổi) *',
                  border: OutlineInputBorder(),
                  hintText: 'VD: 200000',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Số học viên/lớp *',
                  border: OutlineInputBorder(),
                  hintText: 'VD: 2',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Thời gian học/buổi (giờ) *',
                  border: OutlineInputBorder(),
                  hintText: 'VD: 2',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
