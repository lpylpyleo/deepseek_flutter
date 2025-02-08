import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'pages/chat_page.dart';
import 'singletons/widget.dart';
import 'utils/check_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settings');

  // 获取当前版本并检查更新
  final packageInfo = await PackageInfo.fromPlatform();
  Future.delayed(const Duration(seconds: 1), () {
    checkUpdate(packageInfo.version);
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const ChatPage(),
    );
  }
}
