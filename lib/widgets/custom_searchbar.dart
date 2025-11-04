import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  final VoidCallback onFilter;
  final Function(String)? onSubmitted;
  final String? hintText;
  
  const SearchBarCustom({
    super.key, 
    required this.onFilter,
    this.onSubmitted,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'Tìm kiếm...',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Colors.grey[600],
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.blue.shade50,
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                size: 18,
                color: Colors.blue.shade700,
              ),
              onPressed: onFilter,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onSubmitted: onSubmitted ?? (q) {},
      ),
    );
  }
}
