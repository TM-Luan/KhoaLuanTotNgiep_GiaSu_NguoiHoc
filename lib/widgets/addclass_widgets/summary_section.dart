import 'package:flutter/material.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tóm tắt yêu cầu tìm gia sư *"),
        const SizedBox(height: 4),
        TextFormField(
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: 'VD: Tìm gia sư Toán 8 tại Gò Vấp',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
