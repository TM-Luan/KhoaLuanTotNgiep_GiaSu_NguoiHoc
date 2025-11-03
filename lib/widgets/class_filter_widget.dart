import 'package:flutter/material.dart';
import '../data/models/class_filter.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class ClassFilterWidget extends StatefulWidget {
  final ClassFilter initialFilter;
  final Function(ClassFilter) onFilterChanged;
  final Map<String, dynamic>? filterOptions;

  const ClassFilterWidget({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
    this.filterOptions,
  });

  @override
  State<ClassFilterWidget> createState() => _ClassFilterWidgetState();
}

class _ClassFilterWidgetState extends State<ClassFilterWidget> {
  late ClassFilter _currentFilter;
  final TextEditingController _minHocPhiController = TextEditingController();
  final TextEditingController _maxHocPhiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _minHocPhiController.text = _currentFilter.minHocPhi ?? '';
    _maxHocPhiController.text = _currentFilter.maxHocPhi ?? '';
  }

  @override
  void dispose() {
    _minHocPhiController.dispose();
    _maxHocPhiController.dispose();
    super.dispose();
  }

  void _updateFilter() {
    final newFilter = _currentFilter.copyWith(
      minHocPhi: _minHocPhiController.text.isEmpty ? null : _minHocPhiController.text,
      maxHocPhi: _maxHocPhiController.text.isEmpty ? null : _maxHocPhiController.text,
    );
    widget.onFilterChanged(newFilter);
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
            color: Colors.black.withOpacity(0.1),
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
                      _minHocPhiController.clear();
                      _maxHocPhiController.clear();
                    });
                    _updateFilter();
                  },
                  child: const Text('Xóa tất cả'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Môn học
          if (widget.filterOptions?['subjects'] != null) ...[
            const Text('Môn học:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _currentFilter.monHoc,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn môn học',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả môn học'),
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
                  _currentFilter = _currentFilter.copyWith(monHoc: value);
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
                ...widget.filterOptions!['khuVuc']!.map((area) =>
                  DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
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

          // Học phí
          const Text('Học phí (VND/buổi):', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minHocPhiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Từ',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => _updateFilter(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('-'),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _maxHocPhiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Đến',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => _updateFilter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Cấp học
          if (widget.filterOptions?['capHoc'] != null) ...[
            const Text('Cấp học:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _currentFilter.capHoc,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn cấp học',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả cấp học'),
                ),
                ...widget.filterOptions!['capHoc']!.map((level) =>
                  DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilter = _currentFilter.copyWith(capHoc: value);
                });
                _updateFilter();
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Trạng thái
          const Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _currentFilter.trangThai,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Chọn trạng thái',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Tất cả trạng thái'),
              ),
              DropdownMenuItem<String>(
                value: 'TimGiaSu',
                child: Text('Đang tìm gia sư'),
              ),
              DropdownMenuItem<String>(
                value: 'DaCoGiaSu',
                child: Text('Đã có gia sư'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(trangThai: value);
              });
              _updateFilter();
            },
          ),
        ],
      ),
    );
  }
}