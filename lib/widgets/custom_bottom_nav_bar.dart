import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String role;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  List<BottomNavigationBarItem> _buildItems() {
    switch (role) {
      case 'tutor':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: 'Lịch dạy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            label: 'Lớp học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Tài khoản',
          ),
        ];
      case 'learner':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Lịch học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            label: 'Lớp của tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Tài khoản',
          ),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      items: _buildItems(),
    );
  }
}
