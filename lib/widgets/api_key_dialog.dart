import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/client.dart';

class ApiKeyDialog extends HookConsumerWidget {
  const ApiKeyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final mounted = context.mounted;

    return AlertDialog(
      title: const Text('设置 API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '在此输入 API Key',
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://platform.deepseek.com');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('无法打开链接')),
                );
              }
            },
            child: const Text(
              '没有 API Key? 点击这里注册 →',
              style: TextStyle(
                color: Colors.lightBlue,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (controller.text.isEmpty) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key 不能为空')),
              );
              return;
            }

            final box = Hive.box('settings');
            await box.put('apiKey', controller.text);
            if (!mounted) return;
            ref.read(apiKeyProvider.notifier).state = controller.text;
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
