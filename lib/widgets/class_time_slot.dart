import 'package:flutter/material.dart';

class ClassTimeSlot extends StatelessWidget {
  final String text;
  final bool isAvailable;

  const ClassTimeSlot({super.key, required this.text, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
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
}
