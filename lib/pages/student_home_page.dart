import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'tutor_detail_page.dart';
import '../widgets/custom_searchBar.dart';

class LearnerHomePage extends StatelessWidget {
  const LearnerHomePage({super.key});
  final curentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final tutors = _mockTutors;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('https://i.pravatar.cc/300?img=12'),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Xin chào, Trần Minh Luân',
                style: TextStyle(fontSize: 14),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
      ),
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
                            return _TutorCard(
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
      bottomNavigationBar: CustomBottomNavBar(
        role: 'learner',
        currentIndex: 0,
        onTap: (i) {
          if (i == curentIndex) return;
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/student',
              (route) => false,
            );
          } else if (i == 1) {
            Navigator.pushNamed(context, '/schedule');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/my-classes');
          } else {
            Navigator.pushNamed(context, '/account');
          }
        },
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final _Tutor tutor;
  final VoidCallback? onTap;

  const _TutorCard({required this.tutor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E9F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ảnh đại diện
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  tutor.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, size: 40),
                      ),
                ),
              ),
            ),

            // thông tin
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutor.subject,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rate_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      Text(
                        '${tutor.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.group_outlined, size: 15),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${tutor.students} học viên',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
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
class _Tutor {
  final String name;
  final String subject;
  final double rating;
  final int students;
  final String? imageUrl;

  _Tutor({
    required this.name,
    required this.subject,
    required this.rating,
    required this.students,
    required this.imageUrl,
  });
}

final List<_Tutor> _mockTutors = [
  _Tutor(
    name: 'Trần Minh Luân',
    subject: 'Toán - Lý',
    rating: 4.8,
    students: 25,
    imageUrl: 'https://i.pravatar.cc/300?img=1',
  ),
  _Tutor(
    name: 'Nguyễn Hồng Anh',
    subject: 'Tiếng Anh',
    rating: 4.9,
    students: 31,
    imageUrl: 'https://i.pravatar.cc/300?img=2',
  ),
  _Tutor(
    name: 'Lê Hữu Đạt',
    subject: 'Lập trình Flutter',
    rating: 4.7,
    students: 18,
    imageUrl: 'https://i.pravatar.cc/300?img=3',
  ),
  _Tutor(
    name: 'Phạm Thùy Dương',
    subject: 'Hóa học',
    rating: 4.6,
    students: 20,
    imageUrl: 'https://i.pravatar.cc/300?img=4',
  ),
  _Tutor(
    name: 'Ngô Văn Minh',
    subject: 'Vật lý',
    rating: 4.5,
    students: 15,
    imageUrl: 'https://i.pravatar.cc/300?img=5',
  ),
];
