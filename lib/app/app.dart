import 'package:flutter/material.dart';
import 'router.dart';

class GiaSuApp extends StatelessWidget {
  const GiaSuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gia Sư - Kết nối người học',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/splash',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
