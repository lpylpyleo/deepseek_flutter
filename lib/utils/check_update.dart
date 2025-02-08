import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../singletons/widget.dart';

Future<void> checkUpdate(String currentVersion) async {
  final dio = Dio();
  try {
    final response = await dio.get(
        'https://api.github.com/repos/lpylpyleo/deepseek_flutter/releases/latest');

    if (response.statusCode == 200) {
      final data = response.data;
      final latestVersion = (data['tag_name'] as String).replaceAll('v', '');

      if (currentVersion != latestVersion) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('发现新版本'),
            content: Text('当前版本: v$currentVersion\n最新版本: v$latestVersion'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final url = Uri.parse(data['html_url']);
                  await launchUrl(url);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('更新'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('已经是最新版本')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text('检查更新失败：$e')),
    );
  }
}
