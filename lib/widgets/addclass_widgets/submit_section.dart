import 'package:flutter/material.dart';

class SubmitSection extends StatelessWidget {
  final bool agree;
  final Function(bool?) onAgreeChanged;
  final VoidCallback onSubmit;

  const SubmitSection({
    super.key,
    required this.agree,
    required this.onAgreeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: agree,
          onChanged: onAgreeChanged,
          title: const Text(
              "Tôi cam kết thông tin tạo lớp là thật và đồng ý với quy định."),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.send),
            label: const Text("Đăng ký học"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
