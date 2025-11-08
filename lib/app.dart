import 'package:flutter/material.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hackathon MVP',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const MyAppHomeScreen(),
    );
  }
}
