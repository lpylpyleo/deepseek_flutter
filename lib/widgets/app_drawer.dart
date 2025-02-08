import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'api_key_dialog.dart';
import 'package:dio/dio.dart';

class AppDrawer extends HookWidget {
  const AppDrawer({super.key});

  Future<void> _checkUpdate(BuildContext context, String currentVersion) async {
    final dio = Dio();
    try {
      final response = await dio.get(
          'https://api.github.com/repos/lpylpyleo/deepseek_flutter/releases/latest');

      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');

        if (currentVersion != latestVersion) {
          if (!context.mounted) return;
          showDialog(
            context: context,
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
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('更新'),
                ),
              ],
            ),
          );
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已经是最新版本')),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('检查更新失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = useState<String>('');

    useEffect(() {
      PackageInfo.fromPlatform().then((info) {
        version.value = 'v${info.version}';
      });
      return null;
    }, []);

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('修改 API Key'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => const ApiKeyDialog(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('查看源代码'),
                  onTap: () async {
                    final url = Uri.parse(
                        'https://github.com/lpylpyleo/deepseek_flutter');
                    await launchUrl(url);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('检查更新'),
                  onTap: () {
                    Navigator.pop(context);
                    _checkUpdate(context, version.value.replaceAll('v', ''));
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              version.value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
