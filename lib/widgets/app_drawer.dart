import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'api_key_dialog.dart';

class AppDrawer extends HookWidget {
  const AppDrawer({super.key});

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
