import 'package:flutter/material.dart';
import '../data/models/tutor_filter.dart';
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
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Bộ lọc tìm kiếm',
                style: TextStyle(
                  fontSize: 16,
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
                  child: const Text('Xóa tất cả'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Chuyên môn
          if (widget.filterOptions?['subjects'] != null) ...[
            const Text('Chuyên môn:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _currentFilter.chuyenMon,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn chuyên môn',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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
            const SizedBox(height: AppSpacing.md),
          ],

          // Khu vực
          if (widget.filterOptions?['khuVuc'] != null) ...[
            const Text('Khu vực:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _currentFilter.khuVuc,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn khu vực',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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
            const SizedBox(height: AppSpacing.md),
          ],

          // Giới tính
          const Text('Giới tính:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _currentFilter.gioiTinh,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Chọn giới tính',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
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
          const SizedBox(height: AppSpacing.md),

          // Bằng cấp
          if (widget.filterOptions?['bangCap'] != null) ...[
            const Text('Bằng cấp:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _currentFilter.bangCap,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn bằng cấp',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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
            const SizedBox(height: AppSpacing.md),
          ],

          // Kinh nghiệm
          const Text('Kinh nghiệm:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _currentFilter.kinhNghiem,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Chọn mức kinh nghiệm',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
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
    );
  }
}