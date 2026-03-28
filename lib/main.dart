import 'package:flutter/material.dart';
import 'package:os_type/os_type.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 如果需要在鸿蒙上判断是否为PC/Mobile，需要先await OS.initHarmonyDeviceType()
  if (OS.isHarmony) await OS.initHarmonyDeviceType();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
