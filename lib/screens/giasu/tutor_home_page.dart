import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/class_filter.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/class_search_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/class_detail.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/student_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_filter_widget.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/app_components.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class TutorHomePage extends StatefulWidget {
  final UserProfile? userProfile; // THÊM PROPERTY

  const TutorHomePage({super.key, this.userProfile});

  @override
  State<TutorHomePage> createState() => _TutorHomePageState();
}

class _TutorHomePageState extends State<TutorHomePage> {
  final LopHocRepository _lopHocRepo = LopHocRepository();
  final ClassSearchRepository _searchRepo = ClassSearchRepository();
  YeuCauNhanLopRepository? _yeuCauRepo;
  bool _isLoading = true;
  List<LopHoc> _lopHocList = [];
  String? _errorMessage;
  UserProfile? currentProfile;

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFilters = false;
  List<LopHoc> _searchResults = [];
  ClassFilter _currentFilter = ClassFilter();
  Map<String, dynamic>? _filterOptions;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    currentProfile = widget.userProfile;
    _fetchLopHocChuaGiao();
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _yeuCauRepo ??= context.read<YeuCauNhanLopRepository>();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final response = await _searchRepo.getFilterOptions();
      if (response.isSuccess && mounted) {
        setState(() {
          _filterOptions = response.data;
        });
      }
    } catch (e) {
      print('Error loading filter options: $e');
    }
  }

  Future<void> _performSearch({String? query}) async {
    print('🔍 TutorHome: Starting search with query: $query');
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      final response = await _searchRepo.searchClasses(
        query: query,
        filter: _currentFilter.hasActiveFilters ? _currentFilter : null,
      );

      print('🔍 TutorHome: Search response - success: ${response.isSuccess}');
      if (!response.isSuccess) {
        print('🔍 TutorHome: Search error: ${response.message}');
      }

      if (response.isSuccess && mounted) {
        setState(() {
          _searchResults = response.data ?? [];
          _isSearching = false;
        });
        print('🔍 TutorHome: Found ${_searchResults.length} results');
      } else {
        setState(() {
          _isSearching = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    } catch (e) {
      print('💥 TutorHome: Exception during search: $e');
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = null;
      _searchResults.clear();
      _currentFilter = ClassFilter();
      _showFilters = false;
    });
  }

  // GETTERS ĐỂ HIỂN THỊ THÔNG TIN NGƯỜI DÙNG
  String get displayName {
    return currentProfile?.hoTen ?? 'Gia sư';
  }

  String get avatarText {
    final userName = currentProfile?.hoTen ?? '';
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
  }

  Future<void> _fetchLopHocChuaGiao() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ApiResponse<List<LopHoc>> response = await _lopHocRepo
        .getLopHocByTrangThai('TimGiaSu');

    if (mounted) {
      if (response.isSuccess && response.data != null) {
        setState(() {
          _lopHocList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeNghiDay(LopHoc lop) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để gửi đề nghị.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final giaSuId = authState.user.giaSuID;
    final taiKhoanId = authState.user.taiKhoanID;

    if (giaSuId == null || taiKhoanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ gia sư mới có thể gửi đề nghị.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_yeuCauRepo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi hệ thống. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hiển thị dialog nhập ghi chú tùy chọn
    final String? note = await _showNoteDialog();
    if (note == null) {
      return; // Người dùng hủy
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Đang gửi đề nghị...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final response = await _yeuCauRepo!
          .giaSuGuiYeuCau(
            lopId: lop.maLop,
            giaSuId: giaSuId,
            nguoiGuiTaiKhoanId: taiKhoanId,
            ghiChu: note.isEmpty ? null : note, // Cho phép ghi chú trống
          )
          .timeout(Duration(seconds: 10));

      print(
        '📡 Response: success=${response.success}, message=${response.message}',
      );

      // Hide loading snackbar first
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Wait a bit to ensure loading snackbar is completely hidden
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (!mounted) return;

      if (response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Đã gửi đề nghị dạy lớp "${lop.tieuDeLop}" thành công!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Hiển thị thông báo lỗi từ server với màu cam để phân biệt
        final errorMessage =
            (response.message.isNotEmpty)
                ? response.message
                : 'Không thể gửi đề nghị. Vui lòng thử lại.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on TimeoutException catch (e) {
      print('⏰ Request timeout: $e');
      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏰ Yêu cầu quá thời gian. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('💥 Exception trong _handleDeNghiDay: $e');
      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi kết nối: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _navigateToDetail(BuildContext context, LopHoc lop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ClassDetailScreen(classId: lop.maLop, userRole: UserRole.tutor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: StandardAppBar(
        leadingIcon: Icons.class_,
        title: 'Xin chào, $displayName',
        subtitle: 'Tìm kiếm lớp học phù hợp',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Search field with filter button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm lớp học...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchQuery != null
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _clearSearch,
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onSubmitted: (query) {
                            if (query.trim().isNotEmpty) {
                              _performSearch(query: query.trim());
                            } else {
                              _clearSearch();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              _showFilters || _currentFilter.hasActiveFilters
                                  ? AppColors.primary
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color:
                                _showFilters || _currentFilter.hasActiveFilters
                                    ? Colors.white
                                    : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Filter widget
                  if (_showFilters) ...[
                    const SizedBox(height: AppSpacing.md),
                    ClassFilterWidget(
                      initialFilter: _currentFilter,
                      filterOptions: _filterOptions,
                      onFilterChanged: (filter) {
                        setState(() {
                          _currentFilter = filter;
                        });
                        // Auto search when filter changes
                        if (filter.hasActiveFilters || _searchQuery != null) {
                          _performSearch(query: _searchQuery);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Title section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  AppIconContainer(
                    icon: Icons.class_,
                    backgroundColor: AppColors.primaryContainer,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _searchQuery != null || _currentFilter.hasActiveFilters
                        ? 'KẾT QUẢ TÌM KIẾM (${_searchResults.length})'
                        : 'DANH SÁCH LỚP CHƯA GIAO',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTypography.body2,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(child: _buildClassList()),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList() {
    // Show search results if searching or has search query/filter
    if (_searchQuery != null || _currentFilter.hasActiveFilters) {
      return _buildSearchResults();
    }

    // Show default class list
    return _buildDefaultClassList();
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy lớp học nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi từ khóa hoặc bộ lọc',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Sử dụng ListView để card có kích thước cố định, tránh bị kéo dài
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        100,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final lop = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: LopHocCard(
            lopHoc: lop,
            onDeNghiDay: () => _handleDeNghiDay(lop),
            onCardTap: () => _navigateToDetail(context, lop),
          ),
        );
      },
    );
  }

  Widget _buildDefaultClassList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_errorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchLopHocChuaGiao,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lopHocList.isEmpty) {
      return const Center(child: Text('Không có lớp nào cần tìm gia sư.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        100,
      ),
      itemCount: _lopHocList.length,
      itemBuilder: (context, index) {
        final lop = _lopHocList[index];
        return LopHocCard(
          lopHoc: lop,
          onDeNghiDay: () => _handleDeNghiDay(lop),
          onCardTap: () => _navigateToDetail(context, lop),
        );
      },
    );
  }

  // Dialog nhập ghi chú tùy chọn
  Future<String?> _showNoteDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _NoteDialogWidget();
      },
    );
  }
}

// Separate StatefulWidget for the note dialog
class _NoteDialogWidget extends StatefulWidget {
  @override
  _NoteDialogWidgetState createState() => _NoteDialogWidgetState();
}

class _NoteDialogWidgetState extends State<_NoteDialogWidget> {
  late TextEditingController _noteController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gửi đề nghị dạy'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _noteController,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Ghi chú',
            hintText: 'Thêm ghi chú cho đề nghị (tùy chọn)',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.length > 500) {
              return 'Ghi chú tối đa 500 ký tự';
            }
            return null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Trả về null
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_noteController.text.trim());
            }
          },
          child: const Text('Gửi đề nghị'),
        ),
      ],
    );
  }
}
