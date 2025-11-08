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
                      _minHocPhiController.clear();
                      _maxHocPhiController.clear();
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

          // Môn học
          if (widget.filterOptions?['subjects'] != null) ...[
            const Text('Môn học:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _currentFilter.monHoc,
              isDense: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn môn học',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả môn học'),
                ),
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
              onChanged: (value) {
                setState(() {
                  _currentFilter = _currentFilter.copyWith(monHoc: value);
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
            const SizedBox(height: AppSpacing.sm),
          ],

          // Học phí
          const Text('Học phí (VND/buổi):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minHocPhiController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Từ',
                    hintStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (_) => _updateFilter(),
                ),
              ),
              const SizedBox(width: 8),
              const Text('-', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _maxHocPhiController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Đến',
                    hintStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (_) => _updateFilter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Cấp học
          if (widget.filterOptions?['capHoc'] != null) ...[
            const Text('Cấp học:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _currentFilter.capHoc,
              isDense: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn cấp học',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
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
            const SizedBox(height: AppSpacing.sm),
          ],

          // Hình thức (Online/Offline)
          const Text('Hình thức:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _currentFilter.hinhThuc,
            isDense: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Chọn hình thức',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items: const [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Tất cả hình thức'),
              ),
              DropdownMenuItem<String>(
                value: 'Online',
                child: Text('Online'),
              ),
              DropdownMenuItem<String>(
                value: 'Offline',
                child: Text('Offline'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(hinhThuc: value);
              });
              _updateFilter();
            },
          ),
        ],
      ),
    );
  }
}