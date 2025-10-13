import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String? selected;

  void _selectRole(String role) {
    if (selected == role) {
      Navigator.pushNamed(context, '/register');
    } else {
      setState(() => selected = role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/onboarding.png', height: 200), // Thay thế welcome.png bằng onboarding.png
            const SizedBox(height: 20),
            const Text(
              'Tham gia cộng đồng gia sư',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Trở thành một phần của cộng đồng gia sư nhiệt huyết, chia sẻ kiến thức và hợp tác với các nhà giáo dục có cùng chí hướng.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _roleButton('Người học'),
                _roleButton('Gia sư'),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(String label) {
    final isSelected = selected == label;
    return ElevatedButton(
      onPressed: () => _selectRole(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryBlue : AppColors.white,
        foregroundColor: isSelected ? AppColors.white : AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue),
        minimumSize: const Size(130, 45),
      ),
      child: Text(label),
    );
  }
}