import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/client.dart';
import '../utils.dart';

class ApiKeyDialog extends HookConsumerWidget {
  const ApiKeyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final mounted = context.mounted;

    return SimpleDialog(
      title: const Text('设置 API Key'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
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
                  await launchUrl(url);
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
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            if (controller.text.isEmpty) {
              if (!mounted) return;
              showSnackBar(context, 'API Key 不能为空');
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
