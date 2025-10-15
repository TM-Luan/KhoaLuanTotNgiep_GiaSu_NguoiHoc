import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class SearchBarCustom extends StatelessWidget {
  final VoidCallback onFilter;
  const SearchBarCustom({super.key, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Here',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: onFilter,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: (q) {
      },
    );
  }
}
