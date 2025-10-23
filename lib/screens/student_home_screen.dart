import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/tutor_card.dart';
import 'tutor_detail_page.dart';
import '../widgets/custom_searchBar.dart';

class LearnerHomePage extends StatelessWidget {
  const LearnerHomePage({super.key});
  final curentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final tutors = _mockTutors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SearchBarCustom(onFilter: () {}),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                'DANH SÁCH GIA SƯ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.crossAxisExtent >= 420 ? 3 : 2;

                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.66,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final t = tutors[index];
                            return TutorCard(
                              tutor: t,
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    TutorDetailPage.routeName,
                                    arguments: t,
                                  ),
                            );
                          }, childCount: tutors.length),
                        );
                      },
                    ),
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

// ------------------------------
// 🔹 Dữ liệu local (mock data)
// ------------------------------

final List<Tutor> _mockTutors = [
  Tutor(
    name: 'Trần Minh Luân',
    subject: 'Toán - Lý',
    rating: 4.8,
    image: 'https://i.pravatar.cc/300?img=1',
  ),
  Tutor(
    name: 'Nguyễn Hồng Anh',
    subject: 'Tiếng Anh',
    rating: 4.9,
    image: 'https://i.pravatar.cc/300?img=2',
  ),
  Tutor(
    name: 'Lê Hữu Đạt',
    subject: 'Lập trình Flutter',
    rating: 4.7,
    image: 'https://i.pravatar.cc/300?img=3',
  ),
  Tutor(
    name: 'Phạm Thùy Dương',
    subject: 'Hóa học',
    rating: 4.6,
    image: 'https://i.pravatar.cc/300?img=4',
  ),
  Tutor(
    name: 'Ngô Văn Minh',
    subject: 'Vật lý',
    rating: 4.5,
    image: 'https://i.pravatar.cc/300?img=5',
  ),
];
