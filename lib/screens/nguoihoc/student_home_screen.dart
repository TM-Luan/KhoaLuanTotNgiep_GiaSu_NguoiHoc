import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/notification/notification_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/notification/notification_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/notification/notification_state.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/tutor_filter_model.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/lophoc_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/tutor_search_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/yeu_cau_nhan_lop_repository.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/giasu/tutor_detail_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/notification/notification_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/tutor_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/tutor_filter_widget.dart';

class LearnerHomeScreen extends StatefulWidget {
  final UserProfile? userProfile;
  const LearnerHomeScreen({super.key, this.userProfile});

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  UserProfile? currentProfile;
  final LopHocRepository _lopHocRepository = LopHocRepository();
  final TutorSearchRepository _searchRepo = TutorSearchRepository();
  bool _isProcessingInvite = false;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFilters = false;
  List<Tutor> _searchResults = [];
  TutorFilter _currentFilter = TutorFilter();
  Map<String, dynamic>? _filterOptions;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    currentProfile = widget.userProfile;
    // Load danh sách gia sư lần đầu
    context.read<TutorBloc>().add(LoadAllTutorsEvent());
    _loadFilterOptions();
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      final response = await _searchRepo.searchTutors(
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
      _currentFilter = TutorFilter();
      _showFilters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
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
                        'Xin chào, ${currentProfile?.hoTen ?? "Bạn"}!',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Tìm gia sư phù hợp ngay hôm nay',
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
                        // Search Bar
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
                                    hintText: 'Tìm theo môn, tên...',
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
                        // Filters
                        if (_showFilters)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TutorFilterWidget(
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
          body: _buildTutorListView(),
        ),
      ),
    );
  }

  Widget _buildTutorListView() {
    if (_searchQuery != null || _currentFilter.hasActiveFilters) {
      return _buildSearchResults();
    }
    return BlocBuilder<TutorBloc, TutorState>(
      builder: (context, state) {
        if (state is TutorLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TutorErrorState) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        if (state is AllTutorsLoadedState) return _buildGrid(state.tutors);

        // Sửa lỗi: Nếu state không phải là danh sách (ví dụ TutorDetailLoadedState),
        // hiển thị loading để chờ load lại danh sách.
        return const Center(child: CircularProgressIndicator());
      },
    );
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
              'Không tìm thấy kết quả',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return _buildGrid(_searchResults);
  }

  Widget _buildGrid(List<Tutor> tutors) {
    if (tutors.isEmpty) return const Center(child: Text("Không có dữ liệu"));
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: tutors.length,
      itemBuilder: (context, index) {
        final tutor = tutors[index];
        return TutorCard(
          tutor: tutor,
          onTap: () => _navigateToDetail(tutor),
          onOfferTap: _isProcessingInvite ? null : () => _handleOfferTap(tutor),
        );
      },
    );
  }

  void _navigateToDetail(Tutor tutor) {
    // 1. Load chi tiết gia sư vào Bloc
    context.read<TutorBloc>().add(LoadTutorByIdEvent(tutor.giaSuID));

    // 2. Điều hướng sang màn hình chi tiết
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<TutorBloc>(),
              child: TutorDetailPage(),
            ),
      ),
    ).then((_) {
      // 3. QUAN TRỌNG: Khi quay lại (pop), load lại danh sách gia sư
      // để reset state từ TutorDetailLoadedState về AllTutorsLoadedState
      if (mounted) {
        context.read<TutorBloc>().add(LoadAllTutorsEvent());
      }
    });
  }

  void _handleOfferTap(Tutor tutor) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user.nguoiHocID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập tài khoản học viên')),
      );
      return;
    }
    _loadClassesAndPrompt(authState, tutor);
  }

  Future<void> _loadClassesAndPrompt(
    AuthAuthenticated auth,
    Tutor tutor,
  ) async {
    setState(() => _isProcessingInvite = true);
    final response = await _lopHocRepository.getLopHocCuaNguoiHoc();
    setState(() => _isProcessingInvite = false);

    if (!mounted || !response.isSuccess || response.data == null) return;

    final availableClasses =
        response.data!
            .where(
              (l) => [
                'TIMGIASU',
                'CHODUYET',
              ].contains((l.trangThai ?? '').toUpperCase()),
            )
            .toList();
    if (availableClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không có lớp nào đang tìm gia sư')),
      );
      return;
    }

    int selectedClassId = availableClasses.first.maLop;
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mời gia sư dạy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: selectedClassId,
                  decoration: InputDecoration(
                    labelText: 'Chọn lớp',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items:
                      availableClasses
                          .map(
                            (l) => DropdownMenuItem(
                              value: l.maLop,
                              child: Text(
                                l.tieuDeLop,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => selectedClassId = v!,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Lời nhắn (Tuỳ chọn)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.pop(ctx, {
                          'classId': selectedClassId,
                          'note': noteController.text,
                        }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Gửi lời mời',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    if (result != null) {
      _sendInvite(
        tutor: tutor,
        lopId: result['classId'],
        ghiChu: result['note'],
        auth: auth,
      );
    }
  }

  Future<void> _sendInvite({
    required Tutor tutor,
    required int lopId,
    required String? ghiChu,
    required AuthAuthenticated auth,
  }) async {
    setState(() => _isProcessingInvite = true);
    final res = await context.read<YeuCauNhanLopRepository>().nguoiHocMoiGiaSu(
      lopId: lopId,
      giaSuId: tutor.giaSuID,
      nguoiGuiTaiKhoanId: auth.user.taiKhoanID!,
      ghiChu: ghiChu,
    );
    setState(() => _isProcessingInvite = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: res.isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
