import 'package:flutter/material.dart';
import '../data/models/tutor_filter_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  void _updateFilter() {
    widget.onFilterChanged(_currentFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - compact
          Row(
            children: [
              Icon(Icons.filter_list, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_currentFilter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentFilter = _currentFilter.clearAll();
                    });
                    _updateFilter();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Xóa', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Chuyên môn
          if (widget.filterOptions?['subjects'] != null) ...[
            const Text('Chuyên môn:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _currentFilter.chuyenMon,
              isDense: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn chuyên môn',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả chuyên môn'),
                ),
                ...(widget.filterOptions!['subjects'] as List).map((subject) {
                  if (subject is Map<String, dynamic>) {
                    return DropdownMenuItem<String>(
                      value: subject['id'].toString(), // Lưu ID
                      child: Text(subject['name'].toString()), // Hiển thị tên
                    );
                  }
                  return DropdownMenuItem<String>(
                    value: subject.toString(),
                    child: Text(subject.toString()),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilter = _currentFilter.copyWith(chuyenMon: value);
                });
                _updateFilter();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Khu vực
          if (widget.filterOptions?['khuVuc'] != null) ...[
            const Text('Khu vực:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _currentFilter.khuVuc,
              isDense: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn khu vực',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả khu vực'),
                ),
                ...(widget.filterOptions!['khuVuc'] as List).map((area) =>
                  DropdownMenuItem<String>(
                    value: area.toString(),
                    child: Text(area.toString()),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilter = _currentFilter.copyWith(khuVuc: value);
                });
                _updateFilter();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Giới tính và Kinh nghiệm (2 cột)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Giới tính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giới tính:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _currentFilter.gioiTinh,
                      isDense: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Chọn',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      items: const [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Nam',
                          child: Text('Nam'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Nữ',
                          child: Text('Nữ'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _currentFilter = _currentFilter.copyWith(gioiTinh: value);
                        });
                        _updateFilter();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Kinh nghiệm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kinh nghiệm:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _currentFilter.kinhNghiem,
                      isDense: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Chọn',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      items: const [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        DropdownMenuItem<String>(
                          value: '1',
                          child: Text('1 năm'),
                        ),
                        DropdownMenuItem<String>(
                          value: '2',
                          child: Text('2 năm'),
                        ),
                        DropdownMenuItem<String>(
                          value: '3',
                          child: Text('3 năm'),
                        ),
                        DropdownMenuItem<String>(
                          value: '5+',
                          child: Text('5+ năm'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _currentFilter = _currentFilter.copyWith(kinhNghiem: value);
                        });
                        _updateFilter();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Bằng cấp
          if (widget.filterOptions?['bangCap'] != null) ...[
            const Text('Bằng cấp:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _currentFilter.bangCap,
              isDense: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn bằng cấp',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả bằng cấp'),
                ),
                ...(widget.filterOptions!['bangCap'] as List).map((degree) =>
                  DropdownMenuItem<String>(
                    value: degree.toString(),
                    child: Text(degree.toString()),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilter = _currentFilter.copyWith(bangCap: value);
                });
                _updateFilter();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Đánh giá (Rating)
          const Text('Đánh giá tối thiểu:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _currentFilter.minRating,
            isDense: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Chọn đánh giá tối thiểu',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items: const [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Tất cả'),
              ),
              DropdownMenuItem<String>(
                value: '3.0',
                child: Text('⭐ 3.0+'),
              ),
              DropdownMenuItem<String>(
                value: '3.5',
                child: Text('⭐ 3.5+'),
              ),
              DropdownMenuItem<String>(
                value: '4.0',
                child: Text('⭐ 4.0+'),
              ),
              DropdownMenuItem<String>(
                value: '4.5',
                child: Text('⭐ 4.5+'),
              ),
              DropdownMenuItem<String>(
                value: '5.0',
                child: Text('⭐ 5.0'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(minRating: value);
              });
              _updateFilter();
            },
          ),
        ],
      ),
    );
  }
}