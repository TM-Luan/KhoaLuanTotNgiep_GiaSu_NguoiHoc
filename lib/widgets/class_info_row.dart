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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isStatus 
            ? (statusColor?.withOpacity(0.1) ?? Colors.blue.shade50)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isStatus 
                ? statusColor ?? Colors.blue.shade700
                : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isStatus ? FontWeight.w600 : FontWeight.w500,
                color: isStatus 
                    ? statusColor ?? Colors.blue.shade700
                    : Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
