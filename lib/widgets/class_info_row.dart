import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.iconSize = 18,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: labelStyle ??
              TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
      ],
    );
  }
}