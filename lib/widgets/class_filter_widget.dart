import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng FilteringTextInputFormatter
import 'package:intl/intl.dart';
import '../data/models/class_filter_model.dart';
import '../constants/app_colors.dart';

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

  // Format tiền tệ để hiển thị đẹp hơn
  final NumberFormat _currencyFormat = NumberFormat.decimalPattern('vi');

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
      minHocPhi:
          _minHocPhiController.text.isEmpty
              ? null
              : _minHocPhiController.text.replaceAll(',', ''),
      maxHocPhi:
          _maxHocPhiController.text.isEmpty
              ? null
              : _maxHocPhiController.text.replaceAll(',', ''),
    );
    widget.onFilterChanged(newFilter);
  }

  // Input Decoration chuẩn "Clean Style"
  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon:
          icon != null
              ? Icon(icon, size: 18, color: Colors.grey.shade400)
              : null,
      filled: true,
      fillColor: Colors.grey.shade50, // Nền xám rất nhạt
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
                  Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Bộ lọc tìm kiếm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.red.shade400,
                  ),
                  child: const Text('Đặt lại', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF0F0F0)),

          // --- Môn học & Cấp học (Grid 2 cột nếu màn hình rộng, hoặc Column) ---
          _buildLabel('Thông tin lớp'),
          DropdownButtonFormField<String>(
            value: _currentFilter.monHoc,
            isExpanded: true,
            decoration: _inputDecoration(
              'Tất cả môn học',
              icon: Icons.book_outlined,
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Tất cả môn học'),
              ),
              ...(widget.filterOptions?['subjects'] as List? ?? []).map((
                subject,
              ) {
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
                () => _currentFilter = _currentFilter.copyWith(monHoc: val),
              );
              _updateFilter();
            },
          ),
          const SizedBox(height: 12),

          if (widget.filterOptions?['capHoc'] != null)
            DropdownButtonFormField<String>(
              value: _currentFilter.capHoc,
              isExpanded: true,
              decoration: _inputDecoration(
                'Tất cả cấp học',
                icon: Icons.school_outlined,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả cấp học'),
                ),
                ...(widget.filterOptions!['capHoc'] as List).map(
                  (level) => DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(
                  () => _currentFilter = _currentFilter.copyWith(capHoc: val),
                );
                _updateFilter();
              },
            ),

          const SizedBox(height: 16),

          // --- Hình thức & Khu vực ---
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Hình thức'),
                    DropdownButtonFormField<String>(
                      value: _currentFilter.hinhThuc,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        'Chọn',
                        icon: Icons.laptop_mac,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(
                          value: 'Online',
                          child: Text('Online'),
                        ),
                        DropdownMenuItem(
                          value: 'Offline',
                          child: Text('Offline'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(
                          () =>
                              _currentFilter = _currentFilter.copyWith(
                                hinhThuc: val,
                              ),
                        );
                        _updateFilter();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (widget.filterOptions?['khuVuc'] != null)
                Expanded(
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
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ...(widget.filterOptions!['khuVuc'] as List).map(
                            (area) => DropdownMenuItem(
                              value: area,
                              child: Text(
                                area,
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
            ],
          ),

          const SizedBox(height: 16),

          // --- Học phí (Range) ---
          _buildLabel('Khoảng giá (VNĐ/buổi)'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minHocPhiController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration('Tối thiểu'),
                  onChanged: (_) => _updateFilter(),
                ),
              ),
              Container(
                width: 20,
                alignment: Alignment.center,
                child: const Text('-', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(
                child: TextField(
                  controller: _maxHocPhiController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration('Tối đa'),
                  onChanged: (_) => _updateFilter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
