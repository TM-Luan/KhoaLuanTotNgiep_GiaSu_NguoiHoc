// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_response.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/giasu.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/repositories/giasu_repository.dart'; // 1. Import repository mới
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/tutor_card.dart';
import 'tutor_detail_page.dart';
import '../widgets/custom_searchBar.dart';

class LearnerHomeScreen extends StatefulWidget {
  const LearnerHomeScreen({super.key});

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  final curentIndex = 0;

  final GiaSuRepository _giaSuRepo = GiaSuRepository();
  bool _isLoading = true;
  List<Tutor> _tutorList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGiaSu();
  }

  Future<void> _fetchGiaSu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ApiResponse<List<Tutor>> response =
        await _giaSuRepo.getDanhSachGiaSu();

    print('--- KẾT QUẢ GỌI API GIA SƯ ---');
    print('Thành công (Success): ${response.success}');
    print('StatusCode: ${response.statusCode}');
    print('Lỗi (Message): ${response.message}');
    print('Dữ liệu (Data): ${response.data}');
    print('----------------------------------');

    if (mounted) {
      if (response.isSuccess && response.data != null) {
        setState(() {
          _tutorList = response.data!;
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

  Widget _buildTutorList() {
    if (_isLoading) {
      return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_errorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchGiaSu,
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
      );
    }

    if (_tutorList.isEmpty) {
      return const SliverFillRemaining(
          child: Center(child: Text('Không có gia sư nào.')));
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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final t = _tutorList[index];
                return TutorCard(
                  tutor: t,
                  onTap: () => Navigator.pushNamed(
                    context,
                    TutorDetailPage.routeName,
                    arguments: t, 
                  ),
                );
              },
              childCount: _tutorList.length, 
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

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
                  _buildTutorList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

