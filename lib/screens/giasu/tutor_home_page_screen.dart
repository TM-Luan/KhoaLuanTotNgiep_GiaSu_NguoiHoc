import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/notification/notification_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/notification/notification_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/notification/notification_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/lophoc_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/class_filter_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/class_search_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/nguoihoc/class_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/notification/notification_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/class_filter_widget.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

class TutorHomePage extends StatefulWidget {
  final UserProfile? userProfile;
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
    context.read<NotificationBloc>().add(LoadNotifications());
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

  // ... Giữ nguyên logic _loadFilterOptions, _performSearch, _clearSearch, _fetchLopHocChuaGiao, _handleDeNghiDay ...
  Future<void> _loadFilterOptions() async {
    final response = await _searchRepo.getFilterOptions();
    if (response.isSuccess && mounted) {
      setState(() => _filterOptions = response.data);
    }
  }

  Future<void> _performSearch({String? query}) async {
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    try {
      final response = await _searchRepo.searchClasses(
        query: query,
        filter: _currentFilter.hasActiveFilters ? _currentFilter : null,
      );
      if (mounted) {
        setState(() {
          _searchResults = response.isSuccess ? (response.data ?? []) : [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() => _isSearching = false);
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
    if (authState is! AuthAuthenticated || authState.user.giaSuID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ gia sư mới có thể gửi đề nghị.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => _NoteDialogWidget(),
    );
    if (note == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đang gửi đề nghị...')));

    try {
      final response = await _yeuCauRepo!.giaSuGuiYeuCau(
        lopId: lop.maLop,
        giaSuId: authState.user.giaSuID!,
        nguoiGuiTaiKhoanId: authState.user.taiKhoanID!,
        ghiChu: note.isEmpty ? null : note,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  floating: true,
                  pinned: false,
                  snap: true,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, ${currentProfile?.hoTen ?? "Gia sư"}!',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Tìm lớp học phù hợp ngay',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        int unread =
                            (state is NotificationLoaded)
                                ? state.unreadCount
                                : 0;
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: Colors.grey.shade700,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationScreen(),
                                  ),
                                );
                                context.read<NotificationBloc>().add(
                                  LoadNotifications(),
                                );
                              },
                            ),
                            if (unread > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // Search Bar Modern
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    hintText: 'Tìm lớp theo môn, tên...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey.shade400,
                                    ),
                                    suffixIcon:
                                        _searchQuery != null
                                            ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              onPressed: _clearSearch,
                                            )
                                            : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  onSubmitted:
                                      (q) =>
                                          q.trim().isNotEmpty
                                              ? _performSearch(query: q.trim())
                                              : _clearSearch(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap:
                                  () => setState(
                                    () => _showFilters = !_showFilters,
                                  ),
                              child: Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color:
                                      (_showFilters ||
                                              _currentFilter.hasActiveFilters)
                                          ? AppColors.primary
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color:
                                      (_showFilters ||
                                              _currentFilter.hasActiveFilters)
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_showFilters)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ClassFilterWidget(
                              initialFilter: _currentFilter,
                              filterOptions: _filterOptions,
                              onFilterChanged: (filter) {
                                setState(() => _currentFilter = filter);
                                if (filter.hasActiveFilters ||
                                    _searchQuery != null) {
                                  _performSearch(query: _searchQuery);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
          body: _buildClassList(),
        ),
      ),
    );
  }

  Widget _buildClassList() {
    if (_searchQuery != null || _currentFilter.hasActiveFilters) {
      return _buildSearchResults();
    }
    return _buildDefaultClassList();
  }

  Widget _buildSearchResults() {
    if (_isSearching) return const Center(child: CircularProgressIndicator());
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy lớp học',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return _buildListView(_searchResults);
  }

  Widget _buildDefaultClassList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(child: Text('Lỗi: $_errorMessage'));
    }
    if (_lopHocList.isEmpty) {
      return const Center(child: Text('Không có lớp nào cần tìm gia sư.'));
    }
    return _buildListView(_lopHocList);
  }

  Widget _buildListView(List<LopHoc> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final lop = list[index];
        return LopHocCard(
          lopHoc: lop,
          onDeNghiDay: () => _handleDeNghiDay(lop),
          onCardTap: () => _navigateToDetail(context, lop),
        );
      },
    );
  }
}

class _NoteDialogWidget extends StatefulWidget {
  @override
  _NoteDialogWidgetState createState() => _NoteDialogWidgetState();
}

class _NoteDialogWidgetState extends State<_NoteDialogWidget> {
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Gửi đề nghị dạy',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: TextField(
        controller: _noteController,
        maxLines: 3,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: 'Ghi chú (tùy chọn)...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _noteController.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Gửi ngay', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
