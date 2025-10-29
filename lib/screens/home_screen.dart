// screens/home_screen.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_event.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/bloc/auth/auth_state.dart';

import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/user_profile.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/account_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_my_classes_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_schedule_screen.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/student_home_screen.dart'; // Chứa LearnerHomeScreen
// ===> IMPORT TÊN FILE MỚI HOẶC ĐÃ ĐỔI TÊN <===
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_home_page.dart'; // Chứa TutorHomePage
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/screens/tutor_schedule_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // Đổi tên State về public
  HomeScreenState createState() => HomeScreenState();
}

// Đổi tên State về public
class HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  UserProfile? currentProfile;

  @override
  void initState() {
    super.initState();
    // Yêu cầu fetch profile khi vào HomeScreen lần đầu
    // AuthBloc sẽ xử lý và cập nhật state, listener bên dưới sẽ bắt được
    context.read<AuthBloc>().add(const FetchProfileRequested());
  }

  // --- Getters để lấy thông tin từ profile ---
  String get role {
    final userRole = currentProfile?.vaiTro ?? 0;
    if (userRole == 2) {
      return "gia sư";
    } else if (userRole == 3) {
      return "học viên";
    } else {
      return "người dùng"; // Hoặc một vai trò mặc định khác
    }
  }

  String get displayName {
    return currentProfile?.hoTen ?? 'Người dùng';
  }

  String get avatarText {
    final userName = currentProfile?.hoTen ?? '';
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U'; // Viết hoa chữ cái đầu
  }
  // --- Kết thúc Getters ---


  // --- Danh sách các trang dựa trên vai trò ---
  List<Widget> get pages {
    final userRole = currentProfile?.vaiTro ?? 0;

    // ===> BỎ CONST VÀ DÙNG TÊN LỚP ĐÚNG <===
    if (userRole == 2) { // Gia sư
      return [
        const TutorHomePage(), // Dùng tên lớp mới
        const TutorSchedulePage(),
        const Placeholder(), // Tab Lớp của Gia sư (chưa có)
        const Account(),
      ];
    } else if (userRole == 3) { // Học viên
      return [
        const LearnerHomeScreen(), // Tên lớp này đúng từ student_home_screen.dart
        const LearnerSchedulePage(),
        const StudentMyClassesPage(),
        const Account(),
      ];
    } else { // Vai trò không xác định hoặc chưa cập nhật
      return [
        const Center(child: Text('Vui lòng cập nhật vai trò')),
        const Center(child: Text('Vui lòng cập nhật vai trò')),
        const Center(child: Text('Vui lòng cập nhật vai trò')),
        const Account(), // Vẫn cho phép vào Account để cập nhật
      ];
    }
  }
  // --- Kết thúc danh sách trang ---

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // Chỉ lắng nghe khi state thay đổi liên quan đến xác thực hoặc lỗi
      listenWhen: (previousState, currentState) =>
          currentState is AuthAuthenticated ||
          currentState is AuthLoggedOut ||
          currentState is AuthError,
      listener: (context, state) {
        print(">>> [HomeScreen Listener] New Auth State: ${state.runtimeType}"); // Log state thay đổi
        if (state is AuthAuthenticated) {
          // Cập nhật profile và rebuild UI nếu cần
          setState(() => currentProfile = state.user);
           print(">>> [HomeScreen Listener] Profile Updated: ${currentProfile?.hoTen}, Role: ${currentProfile?.vaiTro}");
        } else if (state is AuthLoggedOut) {
          // Đã đăng xuất, quay về màn hình Login
          print(">>> [HomeScreen Listener] Logged out, navigating to /login");
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthError) {
          // Hiển thị lỗi (ví dụ: lỗi fetch profile)
          print(">>> [HomeScreen Listener] Auth Error: ${state.message}");
          // Có thể không cần setState ở đây vì lỗi thường chỉ cần hiển thị SnackBar
          if (mounted) { // Kiểm tra mounted trước khi dùng context
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Lỗi xác thực: ${state.message}')),
             );
          }
          // Nếu lỗi fetch profile khiến currentProfile là null, có thể muốn xử lý thêm
          if (currentProfile == null) {
             print(">>> [HomeScreen Listener] Error fetching profile, profile is null.");
             // Có thể setState để hiển thị thông báo lỗi trên UI chính thay vì SnackBar
          }
        }
      },
      // Build lại UI bất cứ khi nào state thay đổi (kể cả loading)
      buildWhen: (previousState, currentState) => true,
      builder: (context, state) {
         print(">>> [HomeScreen Builder] Building with Auth State: ${state.runtimeType}");
         // Hiển thị loading chỉ khi đang tải lần đầu và chưa có profile
         final isLoading = state is AuthLoading && currentProfile == null;
         print(">>> [HomeScreen Builder] isLoading: $isLoading");

         if (isLoading) {
           return const Scaffold(
             body: Center(child: CircularProgressIndicator()),
           );
         }

         // Nếu không loading, hiển thị UI chính
         return Scaffold(
           appBar: AppBar(
             backgroundColor: AppColors.primaryBlue,
             elevation: 0,
             title: Row(
               children: [
                 CircleAvatar(
                   backgroundColor: Colors.white, // Nền trắng cho avatar
                   child: Text(
                     avatarText,
                     style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                   )
                 ),
                 const SizedBox(width: 10),
                 Text('Xin chào, $displayName', style: const TextStyle(color: Colors.white)), // Chữ trắng
               ],
             ),
             // Có thể thêm nút logout ở đây nếu muốn
             // actions: [
             //   IconButton(
             //     icon: const Icon(Icons.logout, color: Colors.white),
             //     onPressed: () {
             //        print(">>> [HomeScreen] Logout button pressed.");
             //        context.read<AuthBloc>().add(const LogoutRequested());
             //     },
             //   )
             // ],
           ),
           // Body hiển thị trang tương ứng với pageIndex
           body: pages[pageIndex],
           bottomNavigationBar: buildMyNavBar(context),
         );
      },
    );
  }


  // --- Bottom Navigation Bar ---
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 75, // Tăng chiều cao nếu cần
      decoration: BoxDecoration(
        color: AppColors.lightwhite, // Màu nền của nav bar
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            // Sửa lại Alpha để dùng với .round()
            color: AppColors.black.withAlpha((255 * 0.1).round()), // Dùng withAlpha
            offset: const Offset(0, -2), // Vị trí bóng đổ
            blurRadius: 6, // Độ mờ bóng đổ
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Căn đều các item
        children: [
          buildNavItem(icon: Icons.home_filled, label: "Trang chủ", index: 0),
          buildNavItem(icon: Icons.calendar_today, label: "Lịch", index: 1),
          buildNavItem(icon: Icons.class_, label: "Lớp", index: 2), // Đổi icon lớp
          buildNavItem(icon: Icons.person, label: "Tài khoản", index: 3),
        ],
      ),
    );
  }

  Widget buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = pageIndex == index; // Kiểm tra xem item có đang được chọn không

    return Expanded( // Cho phép các item chiếm không gian bằng nhau
      child: GestureDetector(
        onTap: () {
          setState(() {
            pageIndex = index; // Cập nhật index khi nhấn
          });
        },
        behavior: HitTestBehavior.opaque, // Đảm bảo toàn bộ vùng Expanded nhận cử chỉ nhấn
        child: Column(
          mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao cần thiết
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : AppColors.grey, // Màu icon thay đổi
              size: 28, // Kích thước icon
            ),
            const SizedBox(height: 4), // Khoảng cách giữa icon và text
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlue : AppColors.grey, // Màu text thay đổi
                fontSize: 11, // Cỡ chữ
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Độ đậm text
              ),
              maxLines: 1, // Đảm bảo text không xuống dòng
              overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
            ),
          ],
        ),
      ),
    );
  }
  // --- Kết thúc Bottom Navigation Bar ---
}