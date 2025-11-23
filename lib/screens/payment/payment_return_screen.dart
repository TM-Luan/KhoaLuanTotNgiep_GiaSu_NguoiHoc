import 'package:flutter/material.dart';

class PaymentReturnScreen extends StatefulWidget {
  const PaymentReturnScreen({super.key});

  @override
  State<PaymentReturnScreen> createState() => _PaymentReturnScreenState();
}

class _PaymentReturnScreenState extends State<PaymentReturnScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động đóng màn hình này ngay sau khi nó hiện lên
    // Để trả quyền điều khiển lại cho PaymentScreen bên dưới
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Đang xử lý kết quả...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}