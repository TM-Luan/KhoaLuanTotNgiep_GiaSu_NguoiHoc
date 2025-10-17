import 'package:flutter/material.dart';

class ClassInfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isStatus;
  final Color? statusColor;

  const ClassInfoRow({
    super.key,
    required this.icon,
    required this.value,
    this.isStatus = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                color: statusColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
