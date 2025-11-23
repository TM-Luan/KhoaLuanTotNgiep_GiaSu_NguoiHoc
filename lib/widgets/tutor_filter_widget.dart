import 'package:flutter/material.dart';
import '../data/models/tutor_filter_model.dart';
import '../constants/app_colors.dart';

class TutorFilterWidget extends StatefulWidget {
  final TutorFilter initialFilter;
  final Function(TutorFilter) onFilterChanged;
  final Map<String, dynamic>? filterOptions;

  const TutorFilterWidget({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
    this.filterOptions,
  });

  @override
  State<TutorFilterWidget> createState() => _TutorFilterWidgetState();
}

class _TutorFilterWidgetState extends State<TutorFilterWidget> {
  late TutorFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
  }

  void _updateFilter() {
    widget.onFilterChanged(_currentFilter);
  }

  // Reusable Decoration
  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon:
          icon != null
              ? Icon(icon, size: 18, color: Colors.grey.shade400)
              : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tìm kiếm Gia sư',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_currentFilter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    setState(() => _currentFilter = _currentFilter.clearAll());
                    _updateFilter();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.red.shade400,
                  ),
                  child: const Text('Xóa lọc', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF0F0F0)),

          // --- Chuyên môn & Bằng cấp ---
          _buildLabel('Chuyên môn'),
          if (widget.filterOptions?['subjects'] != null)
            DropdownButtonFormField<String>(
              value: _currentFilter.chuyenMon,
              isExpanded: true,
              decoration: _inputDecoration(
                'Chọn chuyên môn',
                icon: Icons.subject,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả')),
                ...(widget.filterOptions!['subjects'] as List).map((subject) {
                  if (subject is Map<String, dynamic>) {
                    return DropdownMenuItem<String>(
                      value: subject['id'].toString(),
                      child: Text(subject['name'].toString()),
                    );
                  }
                  return DropdownMenuItem<String>(
                    value: subject.toString(),
                    child: Text(subject.toString()),
                  );
                }),
              ],
              onChanged: (val) {
                setState(
                  () =>
                      _currentFilter = _currentFilter.copyWith(chuyenMon: val),
                );
                _updateFilter();
              },
            ),

          const SizedBox(height: 12),

          if (widget.filterOptions?['bangCap'] != null) ...[
            _buildLabel('Bằng cấp'),
            DropdownButtonFormField<String>(
              value: _currentFilter.bangCap,
              isExpanded: true,
              decoration: _inputDecoration(
                'Chọn bằng cấp',
                icon: Icons.school_outlined,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả')),
                ...(widget.filterOptions!['bangCap'] as List).map(
                  (degree) => DropdownMenuItem(
                    value: degree.toString(),
                    child: Text(degree.toString()),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(
                  () => _currentFilter = _currentFilter.copyWith(bangCap: val),
                );
                _updateFilter();
              },
            ),
            const SizedBox(height: 16),
          ],

          // --- Hàng 1: Khu vực & Giới tính ---
          Row(
            children: [
              if (widget.filterOptions?['khuVuc'] != null)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Khu vực'),
                      DropdownButtonFormField<String>(
                        value: _currentFilter.khuVuc,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Chọn',
                          icon: Icons.location_on_outlined,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade400,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ...(widget.filterOptions!['khuVuc'] as List).map(
                            (area) => DropdownMenuItem(
                              value: area.toString(),
                              child: Text(
                                area.toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(
                            () =>
                                _currentFilter = _currentFilter.copyWith(
                                  khuVuc: val,
                                ),
                          );
                          _updateFilter();
                        },
                      ),
                    ],
                  ),
                ),
              if (widget.filterOptions?['khuVuc'] != null)
                const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Giới tính'),
                    DropdownButtonFormField<String>(
                      value: _currentFilter.gioiTinh,
                      decoration: _inputDecoration(
                        'Chọn',
                        icon: Icons.person_outline,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                      ],
                      onChanged: (val) {
                        setState(
                          () =>
                              _currentFilter = _currentFilter.copyWith(
                                gioiTinh: val,
                              ),
                        );
                        _updateFilter();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Hàng 2: Kinh nghiệm & Đánh giá ---
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Kinh nghiệm'),
                    DropdownButtonFormField<String>(
                      value: _currentFilter.kinhNghiem,
                      decoration: _inputDecoration(
                        'Chọn',
                        icon: Icons.work_outline,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(value: '1', child: Text('1 năm')),
                        DropdownMenuItem(value: '2', child: Text('2 năm')),
                        DropdownMenuItem(value: '3', child: Text('3 năm')),
                        DropdownMenuItem(value: '5+', child: Text('5+ năm')),
                      ],
                      onChanged: (val) {
                        setState(
                          () =>
                              _currentFilter = _currentFilter.copyWith(
                                kinhNghiem: val,
                              ),
                        );
                        _updateFilter();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Đánh giá'),
                    DropdownButtonFormField<String>(
                      value: _currentFilter.minRating,
                      decoration: _inputDecoration(
                        'Sao',
                        icon: Icons.star_border_rounded,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(value: '3.0', child: Text('> 3.0 ⭐')),
                        DropdownMenuItem(value: '4.0', child: Text('> 4.0 ⭐')),
                        DropdownMenuItem(value: '4.5', child: Text('> 4.5 ⭐')),
                      ],
                      onChanged: (val) {
                        setState(
                          () =>
                              _currentFilter = _currentFilter.copyWith(
                                minRating: val,
                              ),
                        );
                        _updateFilter();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
