import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double size;
  final Color? color;
  final bool showNumber;
  final bool showCount;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.size = 16,
    this.color,
    this.showNumber = true,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showNumber) ...[
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: size * 0.25),
        ],
        Icon(
          Icons.star,
          size: size,
          color: displayColor,
        ),
        if (showCount && totalReviews > 0) ...[
          SizedBox(width: size * 0.25),
          Text(
            '($totalReviews)',
            style: TextStyle(
              fontSize: size * 0.875,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool allowHalf;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.allowHalf = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (allowHalf) {
          if (index < rating.floor()) {
            icon = Icons.star;
          } else if (index < rating) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
        } else {
          icon = index < rating.round() ? Icons.star : Icons.star_border;
        }

        return Icon(
          icon,
          size: size,
          color: displayColor,
        );
      }),
    );
  }
}

class RatingBar extends StatelessWidget {
  final int star;
  final int count;
  final int total;
  final Color? color;

  const RatingBar({
    super.key,
    required this.star,
    required this.count,
    required this.total,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    final displayColor = color ?? Colors.amber;

    return Row(
      children: [
        Text('$star'),
        const SizedBox(width: 4),
        Icon(Icons.star, size: 14, color: displayColor),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(displayColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
