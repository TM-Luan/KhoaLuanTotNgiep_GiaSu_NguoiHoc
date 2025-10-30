import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/tutor/tutor_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_detail_page.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/tutor_card.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/custom_searchBar.dart';

class LearnerHomeScreen extends StatefulWidget {
  final UserProfile? userProfile;

  const LearnerHomeScreen({super.key, this.userProfile});

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  UserProfile? currentProfile;

  @override
  void initState() {
    super.initState();
    currentProfile = widget.userProfile;
    context.read<TutorBloc>().add(LoadAllTutorsEvent());
  }

  String get displayName {
    return currentProfile?.hoTen ?? 'Người dùng';
  }

  String get avatarText {
    final userName = currentProfile?.hoTen ?? '';
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

  Widget _buildTutorList(BuildContext context, TutorState state) {
    if (state is TutorLoadingState) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is TutorErrorState) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: ${state.message}', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.read<TutorBloc>().add(LoadAllTutorsEvent());
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AllTutorsLoadedState) {
      final tutorList = state.tutors;

      if (tutorList.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: Text('Không có gia sư nào.')),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.crossAxisExtent >= 420 ? 3 : 2;

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final tutor = tutorList[index];
                return TutorCard(
                  tutor: tutor,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      TutorDetailPage.routeName,
                      arguments: tutor,
                    );
                  },
                );
              }, childCount: tutorList.length),
            );
          },
        ),
      );
    }

    return const SliverFillRemaining(
      child: Center(child: Text('Vui lòng tải danh sách gia sư')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HIỂN THỊ TÊN NGƯỜI DÙNG
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              color: AppColors.primaryBlue,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Xin chào, $displayName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // PHẦN CÒN LẠI CỦA GIAO DIỆN
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SearchBarCustom(onFilter: () {}),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DANH SÁCH GIA SƯ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<TutorBloc>().add(RefreshTutorsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    tooltip: 'Làm mới danh sách',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  BlocBuilder<TutorBloc, TutorState>(
                    builder: (context, state) {
                      return _buildTutorList(context, state);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
