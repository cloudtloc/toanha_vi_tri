import 'package:flutter/material.dart';

import 'screens/toa_nha_list_screen.dart';

void main() {
  runApp(const ToanhaViTriApp());
}

class ToanhaViTriApp extends StatelessWidget {
  const ToanhaViTriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vi tri toa nha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ToaNhaListScreen(),
    );
  }
}
