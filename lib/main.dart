import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/toa_nha_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ToanhaViTriApp());
}

class ToanhaViTriApp extends StatelessWidget {
  const ToanhaViTriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vị trí toà nhà',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ToaNhaListScreen(),
    );
  }
}
